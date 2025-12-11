part of 'otp_viewmodel.dart';

class OtpState {
  final bool sending;
  final bool verifying;
  final String? verificationId;
  final int? resendToken;
  final bool codeSent;
  final bool verified;
  final String? error;

  OtpState({
    this.sending = false,
    this.verifying = false,
    this.verificationId,
    this.resendToken,
    this.codeSent = false,
    this.verified = false,
    this.error,
  });

  OtpState copyWith({
    bool? sending,
    bool? verifying,
    String? verificationId,
    int? resendToken,
    bool? codeSent,
    bool? verified,
    String? error,
  }) {
    return OtpState(
      sending: sending ?? this.sending,
      verifying: verifying ?? this.verifying,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      codeSent: codeSent ?? this.codeSent,
      verified: verified ?? this.verified,
      error: error ?? this.error,
    );
  }
}
