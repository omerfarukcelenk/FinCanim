part of 'register_viewmodel.dart';

abstract class RegisterEvent {}

class RegisterInitialEvent extends RegisterEvent {}

class UpdateNameEvent extends RegisterEvent {
  final String name;
  UpdateNameEvent(this.name);
}

class UpdateEmailEvent extends RegisterEvent {
  final String email;
  UpdateEmailEvent(this.email);
}

class UpdatePasswordEvent extends RegisterEvent {
  final String password;
  UpdatePasswordEvent(this.password);
}

class UpdatePasswordConfirmEvent extends RegisterEvent {
  final String passwordConfirm;
  UpdatePasswordConfirmEvent(this.passwordConfirm);
}

class UpdateGenderEvent extends RegisterEvent {
  final String gender;
  UpdateGenderEvent(this.gender);
}

class UpdateMaritalStatusEvent extends RegisterEvent {
  final String maritalStatus;
  UpdateMaritalStatusEvent(this.maritalStatus);
}

class UpdateAgeEvent extends RegisterEvent {
  final int? age;
  UpdateAgeEvent(this.age);
}

class SignUpCompletedEvent extends RegisterEvent {}

class SignUpWithGoogleEvent extends RegisterEvent {}
