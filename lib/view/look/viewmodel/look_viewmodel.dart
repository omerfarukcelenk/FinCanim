import 'dart:io';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:falcim_benim/data/models/user_model.dart';
import 'package:falcim_benim/services/firebase_auth_service.dart';
import 'package:falcim_benim/services/fortune_service.dart';
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim_benim/services/firestore_service.dart';
import 'package:falcim_benim/data/models/coffee_reading_model.dart';

class LookViewmodel extends Bloc<LookEvent, LookState> {
  final ImagePicker _picker = ImagePicker();
  final HiveHelper _hive = HiveHelper();

  LookViewmodel() : super(const LookInitial()) {
    on<SelectPhotoEvent>(_onSelectPhoto);
    on<DeletePhotoEvent>(_onDeletePhoto);
    // Use droppable transformer so repeated SaveReadingEvent (e.g., double taps)
    // are ignored while one is being processed.
    on<SaveReadingEvent>(_onSaveReading, transformer: droppable());
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

  Future<void> _onSaveReading(
    SaveReadingEvent event,
    Emitter<LookState> emit,
  ) async {
    try {
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

      // Fortune API çağrısı
      final Map<String, dynamic> resp = await fortuneService.readFortune(
        filesToSend,
        uid,
        token ?? "",
        age: user?.age,
        gender: user?.gender,
        maritalStatus: user?.maritalStatus,
      );

      Logger.debug('Fortune service response: ${resp.toString()}', tag: 'LOOK');

      // ✅ Response kontrolü
      if (resp['success'] == true) {
        final dynamic responseData = resp['data'];

        Logger.debug(
          'Response data type: ${responseData.runtimeType}',
          tag: 'LOOK',
        );
        Logger.debug('Response data: ${responseData.toString()}', tag: 'LOOK');

        String fortuneText = '';

        if (responseData == null) {
          Logger.error('Response data is null!', tag: 'LOOK');
          throw Exception('Fal yorumu boş geldi');
        }

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('fortune')) {
            fortuneText = responseData['fortune']?.toString() ?? '';
          } else {
            Logger.error(
              'Response data does not contain fortune key!',
              tag: 'LOOK',
            );
            Logger.error(
              'Available keys: ${responseData.keys.toList()}',
              tag: 'LOOK',
            );
            throw Exception('Fal yorumu bulunamadı');
          }
        } else if (responseData is String) {
          fortuneText = responseData;
        } else {
          Logger.error(
            'Unexpected data type: ${responseData.runtimeType}',
            tag: 'LOOK',
          );
          throw Exception('Geçersiz veri formatı');
        }

        if (fortuneText.isEmpty) {
          Logger.error('Fortune text is empty!', tag: 'LOOK');
          throw Exception('Fal yorumu boş');
        }

        // Sanitize
        final sanitized = fortuneText.replaceAll(RegExp(r'\*+'), '').trim();
        Logger.success(
          'Fortune received: ${sanitized.substring(0, min(100, sanitized.length))}...',
          tag: 'LOOK',
        );

        final key = await _hive.saveCoffeeReading(model);
        // Model güncelle
        model.reading = sanitized;

        // Firestore'a kaydet
        await HiveHelper().coffeeReadingBox.put(key, model);
        await FirestoreService.instance.addDocument('Fortunes', {
          'ownerId': uid,
          'imagePaths': model.imagePaths,
          'imageCount': model.imagePaths.length,
          'reading': sanitized,
          'notes': model.notes,
          'createdAt': Timestamp.fromDate(model.createdAt),
        });

        Logger.info('Saved fortune to Firestore', tag: 'LOOK');

        // Consume one fortune slot for this reading
        try {
          await PremiumService().incrementFortuneUsage();
        } catch (e) {
          Logger.error('Failed to increment fortune usage: $e', tag: 'LOOK');
        }

        ToastHelper.showSuccess('Falınız alındı');

        emit(LookSaved(key));
      } else {
        // Hata durumu
        final String errorMsg =
            resp['message']?.toString() ?? 'Fal servisi yanıt vermedi';
        Logger.error('Fortune API error: $errorMsg', tag: 'LOOK');
        ToastHelper.showError(errorMsg);
        emit(LookError(errorMsg));
      }
    } catch (e) {
      Logger.error('Error while fetching fortune: $e', tag: 'LOOK');
      ToastHelper.showError('Fal alınırken hata oluştu');
      emit(LookError(e.toString()));
    }
  }
}
