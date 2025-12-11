import 'package:equatable/equatable.dart';

abstract class LookEvent extends Equatable {
  const LookEvent();

  @override
  List<Object?> get props => [];
}

class SelectPhotoEvent extends LookEvent {
  const SelectPhotoEvent();
}

class DeletePhotoEvent extends LookEvent {
  final String path;
  const DeletePhotoEvent(this.path);

  @override
  List<Object?> get props => [path];
}

class SaveReadingEvent extends LookEvent {
  final List<String> paths;
  final String? reading;
  final String? notes;

  const SaveReadingEvent({required this.paths, this.reading, this.notes});

  @override
  List<Object?> get props => [paths, reading, notes];
}
