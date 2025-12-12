part of 'login_viewmodel.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final String email;
  final String password;
  final LoginStatus status;
  final String? errorMessage;

  const LoginState({
    required this.email,
    required this.password,
    required this.status,
    this.errorMessage,
  });

  factory LoginState.initial() => const LoginState(
    email: '',
    password: '',
    status: LoginStatus.initial,
    errorMessage: null,
  );

  LoginState copyWith({
    String? email,
    String? password,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
