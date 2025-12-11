import 'package:bloc/bloc.dart';
import 'detail_event.dart';
import 'detail_state.dart';
import 'package:falcim_benim/data/local/hive_helper.dart';

class DetailViewmodel extends Bloc<DetailEvent, DetailState> {
  final HiveHelper _hive = HiveHelper();

  DetailViewmodel() : super(const DetailInitial()) {
    on<DetailLoadEvent>(_onLoad);
    on<DetailSaveEvent>(_onSave);
    on<DetailShareEvent>(_onShare);
  }

  Future<void> _onLoad(DetailLoadEvent event, Emitter<DetailState> emit) async {
    emit(const DetailLoading());
    try {
      // Try to load by box key first (new behavior). If not found, fall back to positional index for backward compatibility.
      var item = await _hive.getCoffeeReadingByKey(event.index);
      item ??= await _hive.getCoffeeReadingAt(event.index);
      if (item == null) {
        emit(const DetailError(message: 'Record not found'));
      } else {
        // Also fetch user age if available to adjust UI font sizing.
        final user = await _hive.getUserAt(0);
        final int? age = user?.age;
        emit(DetailLoaded(reading: item, userAge: age));
      }
    } catch (e) {
      emit(DetailError(message: e.toString()));
    }
  }

  Future<void> _onSave(DetailSaveEvent event, Emitter<DetailState> emit) async {
    emit(const DetailSaving());
    try {
      // For now the save action is considered instantaneous because items are already in Hive.
      await Future.delayed(const Duration(milliseconds: 300));
      emit(const DetailSaved());
    } catch (e) {
      emit(DetailError(message: e.toString()));
    }
  }

  Future<void> _onShare(
    DetailShareEvent event,
    Emitter<DetailState> emit,
  ) async {
    // Placeholder: sharing should open share sheet; keep state unchanged
    try {
      // no-op for now
    } catch (e) {
      emit(DetailError(message: e.toString()));
    }
  }
}
