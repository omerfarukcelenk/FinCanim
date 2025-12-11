part of 'register_viewmodel.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState {
  final String name;
  final String phone;
  final String gender;
  final String maritalStatus;
  final int? age;
  final RegisterStatus status;
  final String? errorMessage;

  RegisterState({
    this.name = '',
    this.phone = '',
    this.gender = '',
    this.maritalStatus = '',
    this.age,
    this.status = RegisterStatus.initial,
    this.errorMessage,
  });

  RegisterState copyWith({
    String? name,
    String? phone,
    String? gender,
    String? maritalStatus,
    int? age,
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      age: age ?? this.age,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
