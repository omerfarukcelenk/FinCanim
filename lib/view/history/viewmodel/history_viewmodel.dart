import 'package:bloc/bloc.dart';
import 'history_event.dart';
import 'history_state.dart';
import 'package:falcim_benim/data/local/hive_helper.dart';
import 'package:falcim_benim/data/models/coffee_reading_model.dart';
import 'package:falcim_benim/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryViewmodel extends Bloc<HistoryEvent, HistoryState> {
  final HiveHelper _hive = HiveHelper();
  final FirestoreService _fire = FirestoreService.instance;

  /// In-memory mapping of current list index -> firestore document id
  final Map<int, String> _indexToDocId = {};

  HistoryViewmodel() : super(const HistoryInitial()) {
    on<HistoryLoadEvent>(_onLoad);
    on<HistoryRefreshEvent>(_onLoad);
    on<HistoryDeleteEvent>(_onDelete);
  }

  Future<void> _onLoad(HistoryEvent event, Emitter<HistoryState> emit) async {
    emit(const HistoryLoading());
    try {
      // Prefer server-sourced fortunes (Firestore). If user info is available
      // attempt to fetch that user's fortunes. Otherwise fall back to local Hive.
      final user = await _hive.getUserAt(0);
      final uid = user?.uid;

      if (uid != null && uid.isNotEmpty) {
        // Query Firestore for this user's fortunes, order by createdAt desc
        QuerySnapshot snap;
        List<QueryDocumentSnapshot> docs;
        try {
          snap = await _fire
              .collection('Fortunes')
              .where('ownerId', isEqualTo: uid)
              .orderBy('createdAt', descending: true)
              .get();
          docs = snap.docs;
        } on FirebaseException catch (e) {
          // Firestore may require a composite index for certain queries.
          // If so, fall back to a safer query (no orderBy) and sort client-side.
          final msg = e.message ?? e.toString();
          if (msg.contains('requires an index') ||
              msg.contains('failed-precondition')) {
            // Log a helpful hint and perform fallback
            // Attempt to fetch without orderBy and sort locally
            final QuerySnapshot fallback = await _fire
                .collection('Fortunes')
                .where('ownerId', isEqualTo: uid)
                .get();
            docs = fallback.docs;
            // sort docs by createdAt desc if available
            docs.sort((a, b) {
              final ta = (a.data() as Map<String, dynamic>?)?['createdAt'];
              final tb = (b.data() as Map<String, dynamic>?)?['createdAt'];
              final DateTime da = ta is Timestamp
                  ? ta.toDate()
                  : DateTime.now();
              final DateTime db = tb is Timestamp
                  ? tb.toDate()
                  : DateTime.now();
              return db.compareTo(da);
            });
          } else {
            rethrow;
          }
        }

        if (docs.isEmpty) {
          // No remote data; fall back to local Hive contents
          final local = await _hive.getAllCoffeeReadings();
          if (local.isEmpty) {
            emit(const HistoryEmpty());
            return;
          }
          emit(HistoryLoaded(readings: local));
          return;
        }

        // Clear local cache and repopulate to keep Detail/other screens working
        await _hive.clearAllReadings();
        _indexToDocId.clear();

        final List<CoffeeReadingModel> saved = [];
        for (var i = 0; i < docs.length; i++) {
          final d = docs[i];
          final Map<String, dynamic> data = d.data() as Map<String, dynamic>;

          final List<String> imagePaths =
              (data['imagePaths'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              <String>[];

          final String reading = data['reading']?.toString() ?? '';
          final DateTime createdAt = (data['createdAt'] is Timestamp)
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now();
          final String? notes = data['notes']?.toString();

          final model = CoffeeReadingModel(
            imagePaths: imagePaths,
            reading: reading,
            createdAt: createdAt,
            notes: notes,
          );

          final int key = await _hive.saveCoffeeReading(model);
          // Map the positional index to the firestore doc id for potential deletes
          _indexToDocId[saved.length] = d.id;
          saved.add(model);
        }

        final refreshed = await _hive.getAllCoffeeReadings();
        if (refreshed.isEmpty) {
          emit(const HistoryEmpty());
        } else {
          emit(HistoryLoaded(readings: refreshed));
        }
        return;
      }

      // No user id available, fall back to local Hive storage only
      final list = await _hive.getAllCoffeeReadings();
      if (list.isEmpty) {
        emit(const HistoryEmpty());
      } else {
        emit(HistoryLoaded(readings: list));
      }
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }

  Future<void> _onDelete(
    HistoryDeleteEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      // If we have a mapped firestore id for this index, delete remote as well
      final docId = _indexToDocId[event.index];
      if (docId != null && docId.isNotEmpty) {
        try {
          await _fire.deleteDocument('Fortunes/$docId');
        } catch (_) {
          // ignore remote delete errors, proceed to delete local record
        }
      }

      await _hive.deleteCoffeeReading(event.index);
      // rebuild local index mapping after deletion by reloading
      add(const HistoryLoadEvent());
    } catch (e) {
      emit(HistoryError(message: e.toString()));
    }
  }
}
