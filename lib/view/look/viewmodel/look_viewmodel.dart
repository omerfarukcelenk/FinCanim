import 'dart:io';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:falcim_benim/data/models/user_model.dart';
import 'package:falcim_benim/services/firebase_auth_service.dart';
import 'package:falcim_benim/services/fortune_service.dart';
import 'package:falcim_benim/services/local_notification_service.dart';
import 'package:falcim_benim/services/onesignal_service.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:falcim_benim/view/look/viewmodel/look_event.dart';
import 'package:falcim_benim/services/premium_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:falcim_benim/view/look/viewmodel/look_state.dart';
import 'package:falcim_benim/utils/logger.dart';
import 'package:falcim_benim/data/local/hive_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim_benim/services/firestore_service.dart';
import 'package:falcim_benim/data/models/coffee_reading_model.dart';
import 'package:falcim_benim/routes/app_router.dart';

class LookViewmodel extends Bloc<LookEvent, LookState> {
  final ImagePicker _picker = ImagePicker();
  final HiveHelper _hive = HiveHelper();
  late final AppRouter _appRouter;

  LookViewmodel() : super(const LookInitial()) {
    on<SelectPhotoEvent>(_onSelectPhoto);
    on<DeletePhotoEvent>(_onDeletePhoto);
    // Use droppable transformer so repeated SaveReadingEvent (e.g., double taps)
    // are ignored while one is being processed.
    on<SaveReadingEvent>(_onSaveReading, transformer: droppable());
  }

  /// Set app router for navigation
  void setAppRouter(AppRouter router) {
    _appRouter = router;
  }

  FortuneService fortuneService = FortuneService();
  File? savedFile;
  final List<String> _selectedPaths = [];
  Future<void> _onSelectPhoto(
    SelectPhotoEvent event,
    Emitter<LookState> emit,
  ) async {
    try {
      // Do not emit a global loading state for selection; selection is quick.

      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (picked == null) {
        emit(const LookInitial());
        return;
      }

      final tmpDir = await getTemporaryDirectory();
      final id = const Uuid().v4();
      final ext = picked.path.split('.').last;
      final filename = 'coffee_$id.$ext';
      final savedPath = '${tmpDir.path}/$filename';

      // Copy the picked file into cache
      savedFile = await File(picked.path).copy(savedPath);

      // Append to selected list (max 3)
      if (_selectedPaths.length >= 3) {
        ToastHelper.showInfo('En fazla 3 fotoğraf seçebilirsiniz');
        emit(LookSelected(List.from(_selectedPaths)));
        return;
      }
      _selectedPaths.add(savedFile!.path);

      // Emit selected paths; actual persistence happens on explicit Save event
      emit(LookSelected(List.from(_selectedPaths)));
    } on PlatformException catch (e) {
      if (kDebugMode) {
        Logger.debug(
          'LookViewmodel._onSelectPhoto PlatformException: $e',
          tag: 'LOOK',
        );
      }
      // This error often means the native plugin wasn't registered (hot-reload after adding plugin)
      emit(
        const LookError(
          'Platform plugin error: image picker not available. Try a full restart of the app.',
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        Logger.error('LookViewmodel._onSelectPhoto error: $e', tag: 'LOOK');
      }
      emit(LookError(e.toString()));
    }
  }

  Future<void> _onDeletePhoto(
    DeletePhotoEvent event,
    Emitter<LookState> emit,
  ) async {
    try {
      // no global loading state for delete; operation is quick

      final path = event.path;
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
      }

      // remove from Hive too (if previously saved)
      await _hive.deleteCoffeeReadingByPath(path);

      // remove from local selected list
      _selectedPaths.remove(path);

      emit(const LookRemoved());
      if (_selectedPaths.isEmpty) {
        emit(const LookInitial());
      } else {
        emit(LookSelected(List.from(_selectedPaths)));
      }
    } catch (e) {
      if (kDebugMode) {
        Logger.error('LookViewmodel._onDeletePhoto error: $e', tag: 'LOOK');
      }
      emit(LookError(e.toString()));
    }
  }

  /// Poll fortune status from queue until complete
  Future<String?> _pollFortuneStatus(
    String requestId,
    Emitter<LookState> emit,
  ) async {
    const Duration pollInterval = Duration(seconds: 5);
    const int maxPolls = 720; // 60 minutes max
    int pollCount = 0;

    Logger.info(
      'Starting fortune status polling... (max ${maxPolls * 5}s)',
      tag: 'LOOK',
    );

    while (pollCount < maxPolls) {
      pollCount++;

      try {
        // TRIGGER queue processing before checking status
        try {
          await fortuneService.triggerQueueProcessing();
        } catch (e) {
          Logger.debug('Queue trigger failed (non-critical): $e', tag: 'LOOK');
          // Continue - it's okay if queue trigger fails
        }

        // Check status
        final statusResponse = await fortuneService.checkFortuneStatus(
          requestId,
        );

        if (statusResponse['success'] == true) {
          final status = statusResponse['status'];

          if (status == 'completed') {
            final fortune = statusResponse['fortune'];
            if (fortune == null || fortune.toString().isEmpty) {
              throw Exception('Fortune text is empty');
            }
            Logger.success(
              '✅ Fortune ready after ${pollCount * 5} seconds!',
              tag: 'LOOK',
            );
            return fortune.toString();
          } else if (status == 'pending' || status == 'processing') {
            final position = statusResponse['queue_position'] ?? pollCount;
            final estimatedWait =
                statusResponse['estimated_wait'] ?? (pollCount * 5);

            Logger.info(
              '⏳ Processing... Position: $position, Wait: ~${estimatedWait}s',
              tag: 'LOOK',
            );

            // Show UI update (optional - emit custom state if needed)
            emit(LookUploading()); // Reuse uploading state for waiting

            // Wait before next poll
            await Future.delayed(pollInterval);
          }
        } else if (statusResponse['rate_limited'] == true) {
          throw Exception('Rate limited');
        } else {
          throw Exception(statusResponse['message'] ?? 'Status check failed');
        }
      } catch (e) {
        Logger.error('Poll error: $e', tag: 'LOOK');
        // Continue polling even if single request fails
        await Future.delayed(pollInterval);
      }
    }

    throw Exception('Fortune processing timeout (60 minutes exceeded)');
  }

  Future<void> _onSaveReading(
    SaveReadingEvent event,
    Emitter<LookState> emit,
  ) async {
    try {
      final premiumService = PremiumService();

      // Check remaining fortune reading rights
      final remainingRights = await premiumService.getRemainingFortuneCount();

      if (remainingRights <= 0) {
        emit(
          const LookError(
            'Fal bakma hakkınız kalmamıştır. Premium planı yükseltin.',
          ),
        );
        return;
      }

      // Check rate limit (60 seconds between readings)
      final canReadByTime = await premiumService.canReadFortuneByTime();
      if (!canReadByTime) {
        final secondsUntilNext = await premiumService
            .getSecondsUntilNextFortune();
        final message = secondsUntilNext > 1
            ? '$secondsUntilNext saniye sonra tekrar deneyin'
            : '1 saniye sonra tekrar deneyin';
        emit(LookError(message));
        return;
      }

      emit(const LookUploading());

      final model = CoffeeReadingModel(
        imagePaths: event.paths,
        reading: '',
        createdAt: DateTime.now(),
        notes: event.notes,
      );

      FirebaseAuthService firebaseAuthService = FirebaseAuthService.instance;
      String? idToken = await firebaseAuthService.getIdToken();
      UserModel? user = await HiveHelper().getUserAt(0);
      String uid = user?.uid ?? '';
      String? token = user != null ? user.uid : idToken;

      final List<File> filesToSend = event.paths
          .map((p) => File(p))
          .where((f) => f.existsSync())
          .toList();

      // QUEUE SYSTEM: Submit to queue instead of direct API call
      Logger.info('📋 Submitting fortune request to queue...', tag: 'LOOK');

      final queueResponse = await fortuneService.submitFortuneToQueue(
        filesToSend,
        uid,
        name: user?.displayName,
        age: user?.age,
        gender: user?.gender,
        maritalStatus: user?.maritalStatus,
      );

      if (!queueResponse['success']) {
        // Check if rate limited
        if (queueResponse['rate_limited'] == true) {
          final waitMinutes = queueResponse['wait_minutes'] ?? 5;
          final message =
              queueResponse['message'] ?? 'Lütfen $waitMinutes dakika bekleyin';
          Logger.warn('Rate limited: $message', tag: 'LOOK');
          ToastHelper.showError(message);
          emit(LookError(message));
          return;
        }

        // Other errors
        final errorMsg = queueResponse['message'] ?? 'Queue error';
        Logger.error('Queue submit failed: $errorMsg', tag: 'LOOK');
        ToastHelper.showError(errorMsg);
        emit(LookError(errorMsg));
        return;
      }

      // CHECK IF INSTANT RESPONSE (fortune already ready)
      if (queueResponse['instant'] == true) {
        Logger.success('✅ Instant fortune received!', tag: 'LOOK');
        final fortuneText = queueResponse['fortune'] ?? 'Falınız hazır!';

        if (fortuneText.isEmpty) {
          throw Exception('Fortune text is empty');
        }

        // Save fortune
        final key = await HiveHelper().saveCoffeeReading(model);
        model.reading = fortuneText;
        await HiveHelper().coffeeReadingBox.put(key, model);

        await FirestoreService.instance.addDocument('Fortunes', {
          'ownerId': uid,
          'imagePaths': model.imagePaths,
          'imageCount': model.imagePaths.length,
          'reading': fortuneText,
          'notes': model.notes,
          'createdAt': Timestamp.fromDate(model.createdAt),
        });

        // Premium update
        try {
          await PremiumService().incrementFortuneUsage();
          await PremiumService().updateLastFortuneReadTime();
        } catch (e) {
          Logger.error('Failed to update fortune usage: $e', tag: 'LOOK');
        }

        // OneSignal notification
        try {
          await OneSignalService().scheduleDelayedNotification(
            userId: uid,
            title: 'Falınız Hazır! ✨',
            message: 'Kahve falınız bekliyorsunuz. Hemen kontrol edin!',
            delaySeconds: 300,
          );
        } catch (e) {
          Logger.warn('OneSignal scheduling failed: $e', tag: 'LOOK');
        }

        ToastHelper.showSuccess('Falınız 5 dakika içinde hazır olacak! ⏳');

        try {
          _appRouter.push(const HomeRoute());
        } catch (e) {
          emit(LookSaved(key));
        }

        return;
      }

      // SUCCESS: Got request ID, show position (QUEUE MODE)
      final requestId = queueResponse['request_id'];
      final position = queueResponse['queue_position'] ?? 1;
      final estimatedWait = queueResponse['estimated_wait'] ?? 30;

      Logger.success(
        '✅ Queue submitted! ID: $requestId, Position: $position',
        tag: 'LOOK',
      );

      ToastHelper.showInfo(
        'Sırada #$position konumundasınız (~${estimatedWait ~/ 60}min)',
      );

      // POLLING: Wait for fortune to be processed
      Logger.info('Starting polling for fortune...', tag: 'LOOK');
      final fortuneText = await _pollFortuneStatus(requestId, emit);

      if (fortuneText == null) {
        throw Exception('Fortune text is null');
      }

      // Save fortune to local storage
      final key = await HiveHelper().saveCoffeeReading(model);
      model.reading = fortuneText;

      await HiveHelper().coffeeReadingBox.put(key, model);
      Logger.info('Saved fortune to Firestore', tag: 'LOOK');

      // Save to Firestore
      await FirestoreService.instance.addDocument('Fortunes', {
        'ownerId': uid,
        'imagePaths': model.imagePaths,
        'imageCount': model.imagePaths.length,
        'reading': fortuneText,
        'notes': model.notes,
        'createdAt': Timestamp.fromDate(model.createdAt),
      });

      // Consume one fortune slot and update last reading time
      try {
        await PremiumService().incrementFortuneUsage();
        await PremiumService().updateLastFortuneReadTime();
      } catch (e) {
        Logger.error('Failed to update fortune usage/time: $e', tag: 'LOOK');
      }

      // Schedule notification for 5 minutes later via OneSignal
      try {
        await OneSignalService().scheduleDelayedNotification(
          userId: uid,
          title: 'Falınız Hazır! ✨',
          message: 'Kahve falınız bekliyorsunuz. Hemen kontrol edin!',
          delaySeconds: 300, // 5 minutes
        );
        Logger.info('OneSignal delayed notification scheduled', tag: 'LOOK');
      } catch (e) {
        Logger.warn(
          'OneSignal notification scheduling failed: $e',
          tag: 'LOOK',
        );
        // Gracefully continue - app doesn't crash
      }

      // Show toast with notification info
      ToastHelper.showSuccess('Falınız 5 dakika içinde hazır olacak! ⏳');

      // Navigate to Home screen
      try {
        _appRouter.push(const HomeRoute());
        Logger.info('Navigated to home screen', tag: 'LOOK');
      } catch (e) {
        Logger.warn('Failed to navigate home: $e', tag: 'LOOK');
        // Fallback to emit saved state if navigation fails
        emit(LookSaved(key));
      }
    } catch (e) {
      Logger.error('Error while processing fortune: $e', tag: 'LOOK');
      ToastHelper.showError('Fal alınırken hata oluştu');
      emit(LookError(e.toString()));
    }
  }
}
