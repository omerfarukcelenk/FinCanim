import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:falcim_benim/data/models/user_model.dart';
import 'package:falcim_benim/services/firebase_auth_service.dart';
import 'package:falcim_benim/services/fortune_service.dart';
import 'package:falcim_benim/services/onesignal_service.dart';
import 'package:falcim_benim/services/premium_service.dart';
import 'package:falcim_benim/utils/toast_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:falcim_benim/view/look/viewmodel/look_event.dart';
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
    int consecutiveErrors = 0;
    const int maxConsecutiveErrors = 3;

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

        // Check status (with built-in retry logic)
        final statusResponse = await fortuneService.checkFortuneStatus(
          requestId,
        );

        if (statusResponse['success'] == true) {
          consecutiveErrors = 0; // Reset error counter on success
          final status =
              statusResponse['data']['status'] ?? statusResponse['status'];

          if (status == 'completed') {
            final fortune =
                statusResponse['data']['fortune'] ?? statusResponse['fortune'];
            if (fortune == null || fortune.toString().isEmpty) {
              throw Exception('Fortune text is empty');
            }
            Logger.success(
              '✅ Fortune ready after ${pollCount * 5} seconds!',
              tag: 'LOOK',
            );
            return fortune.toString();
          } else if (status == 'pending' || status == 'processing') {
            final position =
                statusResponse['data']['queue_position'] ??
                statusResponse['queue_position'] ??
                pollCount;
            final estimatedWait =
                statusResponse['data']['estimated_wait'] ??
                statusResponse['estimated_wait'] ??
                (pollCount * 5);

            Logger.info(
              '⏳ Processing... Position: $position, Wait: ~${estimatedWait}s',
              tag: 'LOOK',
            );

            // Show UI update
            emit(LookUploading());

            // Wait before next poll
            await Future.delayed(pollInterval);
          } else {
            throw Exception('Unknown status: $status');
          }
        } else {
          throw Exception(statusResponse['message'] ?? 'Status check failed');
        }
      } catch (e) {
        consecutiveErrors++;
        Logger.warn(
          'Poll error (attempt $consecutiveErrors/$maxConsecutiveErrors): $e',
          tag: 'LOOK',
        );

        // If too many consecutive errors, give up
        if (consecutiveErrors >= maxConsecutiveErrors) {
          Logger.error(
            'Too many consecutive errors, stopping polling',
            tag: 'LOOK',
          );
          throw Exception(
            'Polling failed after $maxConsecutiveErrors consecutive errors: $e',
          );
        }

        // Exponential backoff on error
        final backoffDelay = pollInterval * consecutiveErrors;
        Logger.debug(
          'Waiting ${backoffDelay.inSeconds}s before retry...',
          tag: 'LOOK',
        );
        await Future.delayed(backoffDelay);
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

      // QUEUE SYSTEM: Submit to queue in background (non-blocking)
      Logger.info('📋 Submitting fortune request to queue...', tag: 'LOOK');
      emit(const LookUploading());

      // Run queue submission in background to avoid blocking UI
      _submitQueueInBackground(filesToSend, uid, user, model, emit);

      // Immediately return to UI - background task continues
      return;
    } catch (e) {
      Logger.error('Error while processing fortune: $e', tag: 'LOOK');
      ToastHelper.showError('Fal alınırken hata oluştu');
      emit(LookError(e.toString()));
    }
  }

  /// Background task: Submit fortune request to queue without blocking UI
  Future<void> _submitQueueInBackground(
    List<File> filesToSend,
    String uid,
    UserModel? user,
    CoffeeReadingModel model,
    Emitter<LookState> emit,
  ) async {
    try {
      final queueResponse = await fortuneService.submitFortuneToQueue(
        filesToSend,
        uid,
        name: user?.displayName,
        age: user?.age,
        gender: user?.gender,
        maritalStatus: user?.maritalStatus,
      );

      if (!queueResponse['success']) {
        if (queueResponse['rate_limited'] == true) {
          final waitMinutes = queueResponse['wait_minutes'] ?? 5;
          final message =
              queueResponse['message'] ?? 'Lütfen $waitMinutes dakika bekleyin';
          Logger.warn('Rate limited: $message', tag: 'LOOK');
          ToastHelper.showError(message);
          emit(LookError(message));
          return;
        }

        final errorMsg = queueResponse['message'] ?? 'Queue error';
        Logger.error('Queue submit failed: $errorMsg', tag: 'LOOK');
        ToastHelper.showError(errorMsg);
        emit(LookError(errorMsg));
        return;
      }

      // Instant response (cached fortune)
      if (queueResponse['instant'] == true) {
        Logger.success('✅ Instant fortune received!', tag: 'LOOK');
        final fortuneText = queueResponse['fortune'] ?? 'Falınız hazır!';

        if (fortuneText.isEmpty) {
          throw Exception('Fortune text is empty');
        }

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

        try {
          Logger.info(
            'Starting to increment fortune usage (instant)...',
            tag: 'LOOK',
          );
          await PremiumService().incrementFortuneUsage();
          Logger.success('✅ Fortune usage incremented (instant)', tag: 'LOOK');

          Logger.info(
            'Updating last fortune read time (instant)...',
            tag: 'LOOK',
          );
          await PremiumService().updateLastFortuneReadTime();
          Logger.success(
            '✅ Last fortune read time updated (instant)',
            tag: 'LOOK',
          );
        } catch (e) {
          Logger.error(
            '❌ Failed to update fortune usage (instant): $e',
            tag: 'LOOK',
          );
        }

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

      // Queue mode: got request ID, now poll in background
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

      // Fire-and-forget: poll in background without blocking handler
      // Do NOT await this - let it run in the background
      _pollFortuneStatusInBackground(requestId, uid, model, emit).ignore();

      // Return immediately - emit is done
      return;
    } catch (e) {
      Logger.error('Background queue submission error: $e', tag: 'LOOK');
      ToastHelper.showError('Fal alınırken hata oluştu');
      emit(LookError(e.toString()));
    }
  }

  /// Background task: Poll fortune status without blocking UI
  Future<void> _pollFortuneStatusInBackground(
    String requestId,
    String uid,
    CoffeeReadingModel model,
    Emitter<LookState> emit,
  ) async {
    try {
      Logger.info(
        'Starting fortune status polling in background...',
        tag: 'LOOK',
      );

      final fortuneText = await _pollFortuneStatus(requestId, emit);
      if (fortuneText == null) {
        throw Exception('Fortune text is null');
      }

      // Save fortune to local storage
      final key = await HiveHelper().saveCoffeeReading(model);
      model.reading = fortuneText;
      await HiveHelper().coffeeReadingBox.put(key, model);

      // Save to Firestore
      await FirestoreService.instance.addDocument('Fortunes', {
        'ownerId': uid,
        'imagePaths': model.imagePaths,
        'imageCount': model.imagePaths.length,
        'reading': fortuneText,
        'notes': model.notes,
        'createdAt': Timestamp.fromDate(model.createdAt),
      });

      // Update premium stats
      try {
        Logger.info('Starting to increment fortune usage...', tag: 'LOOK');
        await PremiumService().incrementFortuneUsage();
        Logger.success('✅ Fortune usage incremented', tag: 'LOOK');

        Logger.info('Updating last fortune read time...', tag: 'LOOK');
        await PremiumService().updateLastFortuneReadTime();
        Logger.success('✅ Last fortune read time updated', tag: 'LOOK');
      } catch (e) {
        Logger.error('❌ Failed to update fortune usage/time: $e', tag: 'LOOK');
      }

      // Schedule notification
      try {
        await OneSignalService().scheduleDelayedNotification(
          userId: uid,
          title: 'Falınız Hazır! ✨',
          message: 'Kahve falınız bekliyorsunuz. Hemen kontrol edin!',
          delaySeconds: 300,
        );
        Logger.info('OneSignal delayed notification scheduled', tag: 'LOOK');
      } catch (e) {
        Logger.warn(
          'OneSignal notification scheduling failed: $e',
          tag: 'LOOK',
        );
      }

      ToastHelper.showSuccess('Falınız 5 dakika içinde hazır olacak! ⏳');

      try {
        _appRouter.push(const HomeRoute());
        Logger.info('Navigated to home screen', tag: 'LOOK');
      } catch (e) {
        Logger.warn('Failed to navigate home: $e', tag: 'LOOK');
        emit(LookSaved(key));
      }
    } catch (e) {
      Logger.error('Background polling error: $e', tag: 'LOOK');
      ToastHelper.showError('Fal alınırken hata oluştu');
      emit(LookError(e.toString()));
    }
  }
}
