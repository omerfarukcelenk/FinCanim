import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'otp_state.dart';
part 'otp_event.dart';

class OtpViewModel extends Bloc<OtpEvent, OtpState> {
  OtpViewModel() : super(OtpState()) {
    on<OtpInitialEvent>(_initialEvent);
  }

  FutureOr<void> _initialEvent(OtpInitialEvent event, Emitter<OtpState> emit) {}

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
            emit(state.copyWith(sending: false, verified: true));
          } catch (e) {
            emit(state.copyWith(sending: false, error: e.toString()));
          }
        },
        verificationFailed: (e) {
          emit(
            state.copyWith(sending: false, error: e.message ?? e.toString()),
          );
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
      emit(state.copyWith(sending: false, error: e.toString()));
    }
  }

  /// Verify the [smsCode] using the stored verificationId.
  Future<void> verifyCode(String smsCode) async {
    final vid = state.verificationId;
    if (vid == null) {
      emit(state.copyWith(error: 'Doğrulama id bulunamadı'));
      return;
    }
    emit(state.copyWith(verifying: true, error: null));
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: vid,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(cred);
      emit(state.copyWith(verifying: false, verified: true));
    } catch (e) {
      emit(state.copyWith(verifying: false, error: e.toString()));
    }
  }
}
