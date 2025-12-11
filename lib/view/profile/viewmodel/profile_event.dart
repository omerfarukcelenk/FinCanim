part of 'profile_viewmodel.dart';

abstract class ProfileEvent {}

class ProfileInitialEvent extends ProfileEvent {}

class ProfileSignOutEvent extends ProfileEvent {}
