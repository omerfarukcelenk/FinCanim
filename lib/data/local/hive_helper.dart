import 'package:falcim_benim/data/models/user_model.dart';
import 'package:falcim_benim/utils/logger.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/coffee_reading_model.dart';

class HiveHelper {
  static final HiveHelper _instance = HiveHelper._internal();

  factory HiveHelper() {
    return _instance;
  }

  HiveHelper._internal();

  static const String coffeeReadingBoxName = 'coffee_readings';
  static const String userBoxName = 'users';

  late Box<CoffeeReadingModel> _coffeeReadingBox;
  late Box<UserModel> _userBox;

  Box<CoffeeReadingModel> get coffeeReadingBox => _coffeeReadingBox;
  Box<UserModel> get userBox => _userBox;

  Future<void> init() async {
    try {
      // Initialize Hive. Use Hive.initFlutter() which handles platform
      // initialization. Avoid calling path_provider directly here to
      // prevent MissingPluginException in some runtime contexts.
      await Hive.initFlutter();

      // Register adapter
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(CoffeeReadingModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(UserModelAdapter());
      }

      // Open boxes
      _coffeeReadingBox = await Hive.openBox<CoffeeReadingModel>(
        coffeeReadingBoxName,
      );
      _userBox = await Hive.openBox<UserModel>(userBoxName);
    } catch (e) {
      // If initialization fails (e.g. plugin not available in test
      // environment), log a helpful error and rethrow.
      Logger.error('Error initializing Hive: $e', tag: 'HIVE');
      rethrow;
    }
  }

  // Add or update coffee reading — returns the box key for the added item
  Future<int> saveCoffeeReading(CoffeeReadingModel reading) async {
    return await _coffeeReadingBox.add(reading);
  }

  // Add or update user
  Future<int> saveUser(UserModel user) async {
    return await _userBox.add(user);
  }

  // Get all coffee readings
  Future<List<CoffeeReadingModel>> getAllCoffeeReadings() async {
    return _coffeeReadingBox.values.toList();
  }

  // Get all users
  Future<List<UserModel>> getAllUsers() async {
    return _userBox.values.toList();
  }

  // Get coffee reading by index
  Future<CoffeeReadingModel?> getCoffeeReadingAt(int index) async {
    if (index < _coffeeReadingBox.length) {
      return _coffeeReadingBox.getAt(index);
    }
    return null;
  }

  // Get coffee reading by box key
  Future<CoffeeReadingModel?> getCoffeeReadingByKey(int key) async {
    try {
      return _coffeeReadingBox.get(key);
    } catch (e) {
      return null;
    }
  }

  // Get user by index
  Future<UserModel?> getUserAt(int index) async {
    if (index < _userBox.length) {
      return _userBox.getAt(index);
    }
    return null;
  }

  // Update user at index
  Future<void> updateUserAt(int index, UserModel user) async {
    if (index < _userBox.length) {
      await _userBox.putAt(index, user);
    }
  }

  // Delete coffee reading
  Future<void> deleteCoffeeReading(int index) async {
    await _coffeeReadingBox.deleteAt(index);
  }

  // Delete user
  Future<void> deleteUser(int index) async {
    await _userBox.deleteAt(index);
  }

  // Delete coffee reading by matching imagePath; returns true if deleted
  Future<bool> deleteCoffeeReadingByPath(String path) async {
    try {
      final values = _coffeeReadingBox.values.toList();
      for (var i = 0; i < values.length; i++) {
        // support multi-image records: check if any of the stored paths match
        final paths = values[i].imagePaths;
        if (paths.contains(path)) {
          await _coffeeReadingBox.deleteAt(i);
          return true;
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Clear all users
  Future<void> clearAllUsers() async {
    await _userBox.clear();
  }

  // Clear all readings
  Future<void> clearAllReadings() async {
    await _coffeeReadingBox.clear();
  }

  // Close Hive
  Future<void> close() async {
    await Hive.close();
  }
}
