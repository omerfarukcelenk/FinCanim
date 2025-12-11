import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:falcim_benim/data/local/hive_helper.dart';
import 'package:falcim_benim/data/models/user_model.dart';
import 'package:flutter/widgets.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsViewmodel extends Bloc<SettingsEvent, SettingsState> {
  final HiveHelper _hive = HiveHelper();
  // Controllers owned by the viewmodel so UI doesn't manage lifecycle
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  SettingsViewmodel() : super(SettingsState.initial()) {
    on<SettingsInitialEvent>(_initial);
    on<SettingsSaveEvent>(_save);
  }

  /// Convenience method to trigger initial load from UI code.
  void loadInitial() => add(SettingsInitialEvent());

  /// Convenience method to trigger save from UI code.
  void saveSettings({
    required String name,
    required String phoneNumber,
    required String age,
    required String gender,
    required String maritalStatus,
  }) {
    add(
      SettingsSaveEvent(
        name: name,
        phoneNumber: phoneNumber,
        age: age,
        gender: gender,
        maritalStatus: maritalStatus,
      ),
    );
  }

  FutureOr<void> _initial(
    SettingsInitialEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Firestore'dan user bilgilerini çek
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() ?? {};
          final displayName = data['displayName'] ?? '';
          final phone = data['phoneNumber'] ?? currentUser.phoneNumber ?? '';
          final age = data['age']?.toString() ?? '';
          final gender = data['gender'] ?? 'Erkek';
          final maritalStatus = data['maritalStatus'] ?? 'Bekar';

          // populate controllers with Firestore values
          nameController.text = displayName;
          phoneController.text = phone;
          ageController.text = age;

          // Create UserModel from Firestore data
          final user = UserModel(
            uid: currentUser.uid,
            email: currentUser.email ?? '',
            displayName: displayName,
            phoneNumber: phone,
            age: int.tryParse(age),
            gender: gender,
            maritalStatus: maritalStatus,
          );

          emit(
            state.copyWith(
              loading: false,
              name: displayName,
              phoneNumber: phone,
              age: age,
              gender: gender,
              maritalStatus: maritalStatus,
              userModel: user,
            ),
          );
        } else {
          // Firestore document not found, use defaults
          emit(
            state.copyWith(
              loading: false,
              phoneNumber: currentUser.phoneNumber ?? '',
              gender: 'Erkek',
              maritalStatus: 'Bekar',
            ),
          );
        }
      } else {
        // No authenticated user
        emit(state.copyWith(loading: false));
      }
    } catch (e) {
      print('Settings initial error: $e');
      emit(state.copyWith(loading: false));
    }
  }

  FutureOr<void> _save(
    SettingsSaveEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(saving: true));
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Update Firestore
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.uid)
            .update({
              'displayName': event.name,
              'age': int.tryParse(event.age),
              'gender': event.gender,
              'maritalStatus': event.maritalStatus,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        // Update local controllers
        nameController.text = event.name;
        phoneController.text = event.phoneNumber;
        ageController.text = event.age;

        // Update state
        emit(
          state.copyWith(
            saving: false,
            name: event.name,
            phoneNumber: event.phoneNumber,
            age: event.age,
            gender: event.gender,
            maritalStatus: event.maritalStatus,
          ),
        );
      }
    } catch (e) {
      print('Settings save error: $e');
      emit(state.copyWith(saving: false));
    }
  }

  @override
  Future<void> close() {
    nameController.dispose();
    phoneController.dispose();
    ageController.dispose();
    return super.close();
  }
}
