import 'dart:async';

import 'package:falcim_benim/services/firebase_auth_service.dart';
import 'package:falcim_benim/services/premium_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:falcim_benim/data/local/hive_helper.dart';
import 'package:falcim_benim/data/models/user_model.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterViewModel extends Bloc<RegisterEvent, RegisterState> {
  RegisterViewModel() : super(RegisterState.initial()) {
    on<RegisterInitialEvent>(_initialEvent);
    on<UpdateNameEvent>(_onUpdateName);
    on<UpdateEmailEvent>(_onUpdateEmail);
    on<UpdatePasswordEvent>(_onUpdatePassword);
    on<UpdatePasswordConfirmEvent>(_onUpdatePasswordConfirm);
    on<UpdateGenderEvent>(_onUpdateGender);
    on<UpdateMaritalStatusEvent>(_onUpdateMaritalStatus);
    on<UpdateAgeEvent>(_onUpdateAge);
    on<SignUpCompletedEvent>(_onSignUpCompleted);
    on<SignUpWithGoogleEvent>(_onSignUpWithGoogle);
  }

  FutureOr<void> _initialEvent(
    RegisterInitialEvent event,
    Emitter<RegisterState> emit,
  ) {}

  FutureOr<void> _onUpdateName(
    UpdateNameEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(name: event.name, status: RegisterStatus.initial));
  }

  FutureOr<void> _onUpdateEmail(
    UpdateEmailEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: RegisterStatus.initial));
  }

  FutureOr<void> _onUpdatePassword(
    UpdatePasswordEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(password: event.password, status: RegisterStatus.initial),
    );
  }

  FutureOr<void> _onUpdatePasswordConfirm(
    UpdatePasswordConfirmEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        passwordConfirm: event.passwordConfirm,
        status: RegisterStatus.initial,
      ),
    );
  }

  FutureOr<void> _onUpdateGender(
    UpdateGenderEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(gender: event.gender, status: RegisterStatus.initial));
  }

  FutureOr<void> _onUpdateMaritalStatus(
    UpdateMaritalStatusEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(
      state.copyWith(
        maritalStatus: event.maritalStatus,
        status: RegisterStatus.initial,
      ),
    );
  }

  FutureOr<void> _onUpdateAge(
    UpdateAgeEvent event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(age: event.age, status: RegisterStatus.initial));
  }

  Future<void> _onSignUpCompleted(
    SignUpCompletedEvent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      // Validate passwords match
      if (state.password != state.passwordConfirm) {
        throw Exception('Şifreler eşleşmiyor');
      }

      // Sign up with email and password
      await FirebaseAuthService.instance.signUpWithEmail(
        email: state.email,
        password: state.password,
        displayName: state.name,
        gender: state.gender.isNotEmpty ? state.gender : null,
        maritalStatus: state.maritalStatus.isNotEmpty
            ? state.maritalStatus
            : null,
        age: state.age,
      );

      // Initialize FREE plan for new user
      await PremiumService().initializeNewUser(
        displayName: state.name.isNotEmpty ? state.name : null,
        gender: state.gender.isNotEmpty ? state.gender : null,
        maritalStatus: state.maritalStatus.isNotEmpty
            ? state.maritalStatus
            : null,
        age: state.age,
      );

      // Persist to Hive
      final firebaseUser = FirebaseAuthService.instance.currentUser;
      if (firebaseUser != null) {
        final userModel = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? state.name,
          gender: state.gender.isNotEmpty ? state.gender : null,
          maritalStatus: state.maritalStatus.isNotEmpty
              ? state.maritalStatus
              : null,
          age: state.age,
        );
        try {
          await HiveHelper().clearAllUsers();
          await HiveHelper().saveUser(userModel);
        } catch (_) {}
      }

      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSignUpWithGoogle(
    SignUpWithGoogleEvent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      await FirebaseAuthService.instance.signInWithGoogle();

      // Initialize FREE plan for new user
      await PremiumService().initializeNewUser(
        displayName: FirebaseAuthService.instance.currentUser?.displayName,
      );

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
        } catch (_) {}
      }
      emit(state.copyWith(status: RegisterStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
