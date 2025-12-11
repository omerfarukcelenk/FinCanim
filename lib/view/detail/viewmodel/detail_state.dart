import 'package:falcim_benim/data/models/coffee_reading_model.dart';

abstract class DetailState {
  const DetailState();
}

class DetailInitial extends DetailState {
  const DetailInitial();
}

class DetailLoading extends DetailState {
  const DetailLoading();
}

class DetailLoaded extends DetailState {
  final CoffeeReadingModel reading;
  final int? userAge;
  const DetailLoaded({required this.reading, this.userAge});
}

class DetailSaving extends DetailState {
  const DetailSaving();
}

class DetailSaved extends DetailState {
  const DetailSaved();
}

class DetailError extends DetailState {
  final String message;
  const DetailError({required this.message});
}
