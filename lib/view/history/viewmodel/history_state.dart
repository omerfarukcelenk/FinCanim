import 'package:falcim_benim/data/models/coffee_reading_model.dart';

abstract class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoaded extends HistoryState {
  final List<CoffeeReadingModel> readings;
  const HistoryLoaded({required this.readings});
}

class HistoryEmpty extends HistoryState {
  const HistoryEmpty();
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError({required this.message});
}
