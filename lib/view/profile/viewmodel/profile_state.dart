part of 'profile_viewmodel.dart';

enum ProfileStatus { initial, loading, success, failure, signedOut }

class ProfileState {
  final String name;
  final String email;
  final int totalReadings;
  final int remainingRights;
  final ProfileStatus status;
  final String? errorMessage;
  final String? profilePictureUrl;

  ProfileState({
    required this.name,
    required this.email,
    required this.totalReadings,
    required this.remainingRights,
    required this.status,
    this.errorMessage,
    this.profilePictureUrl,
  });

  factory ProfileState.initial() => ProfileState(
    name: '',
    email: '',
    totalReadings: 0,
    remainingRights: 0,
    status: ProfileStatus.initial,
    profilePictureUrl: null,
  );

  ProfileState copyWith({
    String? name,
    String? email,
    int? totalReadings,
    int? remainingRights,
    ProfileStatus? status,
    String? errorMessage,
    String? profilePictureUrl,
  }) {
    return ProfileState(
      name: name ?? this.name,
      email: email ?? this.email,
      totalReadings: totalReadings ?? this.totalReadings,
      remainingRights: remainingRights ?? this.remainingRights,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
    );
  }
}
