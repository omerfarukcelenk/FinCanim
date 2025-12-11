part of 'settings_viewmodel.dart';

class SettingsEvent {}

class SettingsInitialEvent extends SettingsEvent {}

class SettingsSaveEvent extends SettingsEvent {
  final String name;
  final String phoneNumber;
  final String age;
  final String gender;
  final String maritalStatus;

  SettingsSaveEvent({
    required this.name,
    required this.phoneNumber,
    required this.age,
    required this.gender,
    required this.maritalStatus,
  });
}
