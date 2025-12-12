part of 'login_viewmodel.dart';

abstract class LoginEvent {}

class LoginInitialEvent extends LoginEvent {}

class UpdateEmailEvent extends LoginEvent {
  final String email;
  UpdateEmailEvent(this.email);
}

class UpdatePasswordEvent extends LoginEvent {
  final String password;
  UpdatePasswordEvent(this.password);
}

class SignInCompletedEvent extends LoginEvent {}

class SignInWithGoogleEvent extends LoginEvent {}
