part of 'login_viewmodel.dart';

abstract class LoginEvent {}

class LoginInitialEvent extends LoginEvent {}

class UpdatePhoneEvent extends LoginEvent {
  final String phone;
  UpdatePhoneEvent(this.phone);
}

class SignInCompletedEvent extends LoginEvent {}

class SignInWithGoogleEvent extends LoginEvent {}
