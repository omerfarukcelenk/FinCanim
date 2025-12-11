import 'package:equatable/equatable.dart';

abstract class LookState extends Equatable {
  const LookState();

  @override
  List<Object?> get props => [];
}

class LookInitial extends LookState {
  const LookInitial();
}

class LookLoading extends LookState {
  const LookLoading();
}

class LookUploading extends LookState {
  const LookUploading();
}

class LookSelected extends LookState {
  final List<String> paths;
  const LookSelected(this.paths);

  @override
  List<Object?> get props => [paths];
}

class LookError extends LookState {
  final String message;
  const LookError(this.message);

  @override
  List<Object?> get props => [message];
}

class LookRemoved extends LookState {
  const LookRemoved();
}

class LookSaved extends LookState {
  final int key;
  const LookSaved(this.key);

  @override
  List<Object?> get props => [key];
}
