import 'package:flutter/material.dart';

class SplashEvent {}

class SplashInitialEvent extends SplashEvent {
  BuildContext context;
  SplashInitialEvent({required this.context});
}
