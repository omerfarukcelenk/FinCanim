part of 'register_viewmodel.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState {
  final String name;
  final String email;
  final String password;
  final String passwordConfirm;
  final String gender;
  final String maritalStatus;
  final int? age;
  final RegisterStatus status;
  final String? errorMessage;

  const RegisterState({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirm,
    required this.gender,
    required this.maritalStatus,
    this.age,
    required this.status,
    this.errorMessage,
  });

  factory RegisterState.initial() => const RegisterState(
    name: '',
    email: '',
    password: '',
    passwordConfirm: '',
    gender: '',
    maritalStatus: '',
    age: null,
    status: RegisterStatus.initial,
    errorMessage: null,
  );

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    String? passwordConfirm,
    String? gender,
    String? maritalStatus,
    int? age,
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      passwordConfirm: passwordConfirm ?? this.passwordConfirm,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      age: age ?? this.age,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
