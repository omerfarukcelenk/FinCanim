import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:falcim_benim/routes/app_router.dart';
import 'package:falcim_benim/data/local/hive_helper.dart';
import 'package:falcim_benim/view/splash/viewmodel/splash_event.dart';
import 'package:falcim_benim/view/splash/viewmodel/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashViewmodel extends Bloc<SplashEvent, SplashState> {
  SplashViewmodel() : super(SplashState()) {
    on<SplashInitialEvent>(_initialEvent);
  }

  FutureOr<void> _initialEvent(
    SplashInitialEvent event,
    Emitter<SplashState> emit,
  ) async {
    // Keep splash visible for a short duration
    await Future.delayed(const Duration(seconds: 1));

    try {
      final userBox = HiveHelper().userBox;
      // If no user saved, go to Login; otherwise go to Home
      if (userBox.isEmpty) {
        event.context.router.replace(const LoginRoute());
      } else {
        event.context.router.replace(const HomeRoute());
      }
    } catch (e) {
      // If Hive isn't available or some error occurs, default to Login
      event.context.router.replace(const LoginRoute());
    }
  }
}
