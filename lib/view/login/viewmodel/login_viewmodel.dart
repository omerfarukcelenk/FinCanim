import 'dart:async';

import 'package:falcim_benim/services/firebase_auth_service.dart';
import 'package:falcim_benim/data/local/hive_helper.dart';
import 'package:falcim_benim/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  LoginViewModel() : super(LoginState()) {
    on<LoginInitialEvent>(_initialEvent);
    on<SignInCompletedEvent>(_onSignInCompleted);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
  }

  FutureOr<void> _initialEvent(
    LoginInitialEvent event,
    Emitter<LoginState> emit,
  ) {}

  FutureOr<void> _onUpdateEmail(
    UpdatePhoneEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(phone: event.phone, status: LoginStatus.initial));
  }

  Future<void> _onSignInCompleted(
    SignInCompletedEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      // After OTP flow the FirebaseAuth currentUser should be set
      final firebaseUser = FirebaseAuthService.instance.currentUser;
      if (firebaseUser == null) throw Exception('Kullanıcı doğrulanmadı');

      // Ensure Firestore user document exists (create minimal if needed)
      await FirebaseAuthService.instance.ensureUserDocument();

      // Persist authenticated user to Hive
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        phoneNumber: firebaseUser.phoneNumber,
      );
      try {
        await HiveHelper().clearAllUsers();
        await HiveHelper().saveUser(userModel);
      } catch (_) {
        // ignore hive save errors but continue
      }

      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onSignInWithGoogle(
    SignInWithGoogleEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      await FirebaseAuthService.instance.signInWithGoogle();
      // Persist authenticated user to Hive
      final firebaseUser = FirebaseAuthService.instance.currentUser;
      if (firebaseUser != null) {
        final userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          phoneNumber: firebaseUser.phoneNumber,
        );
        try {
          await HiveHelper().clearAllUsers();
          await HiveHelper().saveUser(userModel);
        } catch (_) {
          // ignore hive save errors but continue
        }
      }
      emit(state.copyWith(status: LoginStatus.success));
    } catch (e) {
      emit(
        state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()),
      );
    }
  }
}
