part of 'register_viewmodel.dart';

abstract class RegisterEvent {}

class RegisterInitialEvent extends RegisterEvent {}

class UpdateNameEvent extends RegisterEvent {
  final String name;
  UpdateNameEvent(this.name);
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

class UpdatePhoneEvent extends RegisterEvent {
  final String phone;
  UpdatePhoneEvent(this.phone);
}

class SignUpCompletedEvent extends RegisterEvent {}

class SignUpWithGoogleEvent extends RegisterEvent {}
