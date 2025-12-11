import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:falcim_benim/services/firestore_service.dart';
import 'package:falcim_benim/view/home/viewmodel/home_event.dart';
import 'package:falcim_benim/view/home/viewmodel/home_state.dart';

class HomeViewmodel extends Bloc<HomeEvent, HomeState> {
  HomeViewmodel() : super(HomeState()) {
    on<HomeInitialEvent>(_initialEvent);
  }

  FirestoreService firestoreService = FirestoreService.instance;
  Future<void> _initialEvent(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {}
}
