import 'dart:async';

import 'package:falcim_benim/services/firebase_auth_service.dart';
import 'package:falcim_benim/data/local/hive_helper.dart';
import 'package:falcim_benim/data/models/user_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginViewModel extends Bloc<LoginEvent, LoginState> {
  LoginViewModel() : super(LoginState.initial()) {
    on<LoginInitialEvent>(_initialEvent);
    on<UpdateEmailEvent>(_onUpdateEmail);
    on<UpdatePasswordEvent>(_onUpdatePassword);
    on<SignInCompletedEvent>(_onSignInCompleted);
    on<SignInWithGoogleEvent>(_onSignInWithGoogle);
  }

  FutureOr<void> _initialEvent(
    LoginInitialEvent event,
    Emitter<LoginState> emit,
  ) {}

  FutureOr<void> _onUpdateEmail(
    UpdateEmailEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: LoginStatus.initial));
  }

  FutureOr<void> _onUpdatePassword(
    UpdatePasswordEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, status: LoginStatus.initial));
  }

  Future<void> _onSignInCompleted(
    SignInCompletedEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    try {
      // Sign in with email and password
      await FirebaseAuthService.instance.signInWithEmail(
        email: state.email,
        password: state.password,
      );

      // Get current Firebase user
      final firebaseUser = FirebaseAuthService.instance.currentUser;
      if (firebaseUser == null) throw Exception('Kullanıcı doğrulanmadı');

      // Persist authenticated user to Hive
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
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
