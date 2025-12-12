part of 'settings_viewmodel.dart';

class SettingsState {
  final bool loading;
  final bool saving;
  final String name;
  final String email;
  final String age;
  final String gender;
  final String maritalStatus;
  final dynamic userModel;

  SettingsState({
    required this.loading,
    required this.saving,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.maritalStatus,
    this.userModel,
  });

  factory SettingsState.initial() => SettingsState(
    loading: false,
    saving: false,
    name: '',
    email: '',
    age: '',
    gender: 'Erkek',
    maritalStatus: 'Bekar',
    userModel: null,
  );

  SettingsState copyWith({
    bool? loading,
    bool? saving,
    String? name,
    String? email,
    String? age,
    String? gender,
    String? maritalStatus,
    dynamic userModel,
  }) {
    return SettingsState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      userModel: userModel ?? this.userModel,
    );
  }
}
