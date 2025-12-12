import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:falcim_benim/utils/logger.dart';

part 'otp_state.dart';
part 'otp_event.dart';

class OtpViewModel extends Bloc<OtpEvent, OtpState> {
  OtpViewModel() : super(OtpState()) {
    on<OtpInitialEvent>(_initialEvent);
  }

  FutureOr<void> _initialEvent(OtpInitialEvent event, Emitter<OtpState> emit) {}

  /// Map Firebase error codes to user-friendly messages (Türkçe/English support).
  String _mapFirebaseErrorToMessage(Object error) {
    if (error is FirebaseAuthException) {
      Logger.error('FirebaseAuth error: ${error.code} - ${error.message}');
      switch (error.code) {
        case 'BILLING_NOT_ENABLED':
          return 'SMS servisi etkinleştirilmedi. Firebase Console\'dan test numarası ekleyin veya faturalandırmayı kontrol edin.';
        case 'TOO_MANY_REQUESTS':
          return 'Çok fazla deneme yapıldı. Lütfen birkaç dakika bekleyin.';
        case 'SESSION_EXPIRED':
          return 'Oturum süresi doldu. Lütfen yeniden başlayın.';
        case 'INVALID_PHONE_NUMBER':
          return 'Geçersiz telefon numarası. Lütfen kontrol edin.';
        case 'INVALID_VERIFICATION_CODE':
          return 'Geçersiz doğrulama kodu. Lütfen yeniden deneyin.';
        case 'NETWORK_REQUEST_FAILED':
          return 'Ağ bağlantısı başarısız. İnternet bağlantısını kontrol edin.';
        default:
          return error.message ??
              'Doğrulama sırasında bir hata oluştu. Lütfen yeniden deneyin.';
      }
    }
    Logger.error('Unexpected error: $error');
    return 'Beklenmeyen bir hata oluştu.';
  }

  /// Send verification code to [phone]. Emits state changes for sending, codeSent, and errors.
  Future<void> sendCode(String phone, {bool forceResend = false}) async {
    emit(state.copyWith(sending: true, error: null));
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            emit(state.copyWith(sending: false, verified: true, error: null));
          } catch (e) {
            final errorMsg = _mapFirebaseErrorToMessage(e);
            emit(state.copyWith(sending: false, error: errorMsg));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          final errorMsg = _mapFirebaseErrorToMessage(e);
          emit(state.copyWith(sending: false, error: errorMsg));
        },
        codeSent: (verificationId, forceResendingToken) {
          emit(
            state.copyWith(
              sending: false,
              codeSent: true,
              verificationId: verificationId,
              resendToken: forceResendingToken,
              error: null,
            ),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          emit(state.copyWith(verificationId: verificationId));
        },
        forceResendingToken: forceResend ? state.resendToken : null,
      );
    } catch (e) {
      final errorMsg = _mapFirebaseErrorToMessage(e);
      emit(state.copyWith(sending: false, error: errorMsg));
    }
  }

  /// Verify the [smsCode] using the stored verificationId.
  Future<void> verifyCode(String smsCode) async {
    final vid = state.verificationId;
    if (vid == null) {
      emit(
        state.copyWith(
          error: 'Doğrulama ID bulunamadı. Lütfen kodu yeniden gönderin.',
        ),
      );
      return;
    }
    emit(state.copyWith(verifying: true, error: null));
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(cred);
      emit(state.copyWith(verifying: false, verified: true, error: null));
    } catch (e) {
      final errorMsg = _mapFirebaseErrorToMessage(e);
      emit(state.copyWith(verifying: false, error: errorMsg));
    }
  }
}
