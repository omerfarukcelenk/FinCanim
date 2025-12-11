part of 'login_viewmodel.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final String phone;
  final LoginStatus status;
  final String? errorMessage;

  LoginState({
    this.phone = '',
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  LoginState copyWith({
    String? phone,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      phone: phone ?? this.phone,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
