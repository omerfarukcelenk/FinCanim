part of 'settings_viewmodel.dart';

class SettingsState {
  final bool loading;
  final bool saving;
  final String name;
  final String phoneNumber;
  final String age;
  final String gender;
  final String maritalStatus;
  final dynamic userModel;

  SettingsState({
    required this.loading,
    required this.saving,
    required this.name,
    required this.phoneNumber,
    required this.age,
    required this.gender,
    required this.maritalStatus,
    this.userModel,
  });

  factory SettingsState.initial() => SettingsState(
    loading: false,
    saving: false,
    name: '',
    phoneNumber: '',
    age: '',
    gender: 'Erkek',
    maritalStatus: 'Bekar',
    userModel: null,
  );

  SettingsState copyWith({
    bool? loading,
    bool? saving,
    String? name,
    String? phoneNumber,
    String? age,
    String? gender,
    String? maritalStatus,
    dynamic userModel,
  }) {
    return SettingsState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      userModel: userModel ?? this.userModel,
    );
  }
}
