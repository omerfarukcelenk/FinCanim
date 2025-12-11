import 'dart:async';

import 'package:falcim_benim/data/local/hive_helper.dart';
import 'package:falcim_benim/data/models/user_model.dart';
import 'package:falcim_benim/services/firebase_auth_service.dart';
import 'package:falcim_benim/services/premium_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileViewmodel extends Bloc<ProfileEvent, ProfileState> {
  ProfileViewmodel() : super(ProfileState.initial()) {
    on<ProfileInitialEvent>(_onInitial);
    on<ProfileSignOutEvent>(_onSignOut);
  }

  FutureOr<void> _onInitial(
    ProfileInitialEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      // Load user from Hive (first user)
      final users = await HiveHelper().getAllUsers();
      UserModel? user;
      if (users.isNotEmpty) user = users.first;

      // Load readings from Firestore via PremiumService
      final totalReadings = await PremiumService().getTotalReadings();
      final remainingReadings = await PremiumService().getRemainingReadings();

      emit(
        state.copyWith(
          name: user?.displayName ?? 'Kullanıcı Adı',
          email: user?.email ?? '',
          totalReadings: totalReadings,
          remainingRights: remainingReadings,
          profilePictureUrl: user?.profilePictureUrl,
          status: ProfileStatus.success,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSignOut(
    ProfileSignOutEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      await FirebaseAuthService.instance.signOut();
      await HiveHelper().clearAllUsers();
      emit(state.copyWith(status: ProfileStatus.signedOut));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
