import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim_benim/data/models/fortune_slot_model.dart';
import 'package:falcim_benim/data/models/premium_model.dart';
import 'package:falcim_benim/data/models/usage_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PremiumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  // Constants
  static const int MAX_FORTUNE_SLOTS = 2;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // ==================== PREMIUM CHECK ====================

  // Stream that emits current slot states and updates every minute.
  // UI can subscribe to `slotStateStream` to get live countdowns.
  final StreamController<List<PremiumSlotState>> _slotController =
      StreamController<List<PremiumSlotState>>.broadcast();

  Timer? _slotTimer;
  bool _slotStreamInitialized = false;

  /// Public stream of current slot states (two slots by default).
  Stream<List<PremiumSlotState>> get slotStateStream {
    _ensureSlotTimerStarted();
    return _slotController.stream;
  }

  void _ensureSlotTimerStarted() {
    if (_slotStreamInitialized) return;
    _slotStreamInitialized = true;
    // Emit immediately, then every minute
    _emitCurrentSlotStates();
    _slotTimer = Timer.periodic(Duration(minutes: 1), (_) {
      _emitCurrentSlotStates();
    });
  }

  /// Dispose slot stream resources. Call when app terminates or when no longer needed.
  void dispose() {
    _slotTimer?.cancel();
    try {
      if (!_slotController.isClosed) _slotController.close();
    } catch (_) {}
  }

  /// Force immediate refresh of slot states (useful after login/usage change).
  Future<void> refreshSlotStates() async {
    await _emitCurrentSlotStates();
  }

  /// Initialize free plan for new user (call on signup)
  /// Optional parameters for user profile data
  Future<bool> initializeNewUser({
    String? displayName,
    String? gender,
    String? maritalStatus,
    int? age,
    String? phoneNumber,
  }) async {
    if (_userId == null) return false;

    try {
      final now = DateTime.now();
      final expiryDate = now.add(Duration(days: 30));

      // Create FREE plan
      final premium = PremiumModel(
        isPremium: false,
        purchaseDate: now,
        expiryDate: expiryDate,
        plan: "free",
        autoRenew: false,
        platform: null,
      );

      // Create 7 slots for free plan
      final usage = UsageModel(
        fortuneSlots: List.generate(
          7,
          (i) => FortuneSlot(usedAt: DateTime.now(), isUsed: false),
        ),
        totalFortunes: 0,
        monthlyResetDate: now,
      );

      // Get current Firebase user info
      final currentUser = _auth.currentUser;

      // Update user document with premium, usage, and user info
      await _firestore.collection('Users').doc(_userId).set({
        'email': currentUser?.email,
        'displayName': displayName ?? currentUser?.displayName,
        'phoneNumber': phoneNumber ?? currentUser?.phoneNumber,
        'createdAt': now,
        'updatedAt': now,
        'gender': gender,
        'maritalStatus': maritalStatus,
        'age': age,
        'premium': premium.toMap(),
        'usage': usage.toMap(),
        // Keep existing user data
        'isPremium': false,
        'plan': 'free',
        'premiumExpiryDate': expiryDate,
        'totalReadings': 0,
        'remaningReadings': 7,
      }, SetOptions(merge: true));

      await refreshSlotStates();
      return true;
    } catch (e) {
      print('Error initializing new user: $e');
      return false;
    }
  }

  /// Check if user is initialized (has premium/usage data)
  Future<bool> isUserInitialized() async {
    if (_userId == null) return false;

    try {
      final doc = await _firestore.collection('Users').doc(_userId).get();
      if (!doc.exists) return false;

      final hasPremium = doc.data()?['premium'] != null;
      final hasUsage = doc.data()?['usage'] != null;

      return hasPremium && hasUsage;
    } catch (e) {
      print('Error checking user initialization: $e');
      return false;
    }
  }

  /// Ensure user is initialized, if not create free plan
  Future<void> ensureUserInitialized() async {
    if (_userId == null) return;

    try {
      final initialized = await isUserInitialized();
      if (!initialized) {
        await initializeNewUser();
      }
    } catch (e) {
      print('Error ensuring user initialization: $e');
    }
  }

  /// Ensure plan is valid: check expiry and downgrade if needed
  Future<void> _ensurePlanValid() async {
    if (_userId == null) return;

    try {
      // First ensure user is initialized
      await ensureUserInitialized();

      final doc = await _firestore.collection('Users').doc(_userId).get();
      if (!doc.exists) return;

      final premiumData = doc.data()?['premium'];
      if (premiumData == null) return;

      final premium = PremiumModel.fromMap(premiumData);

      // Check if should downgrade to free
      if (premium.shouldDowngradeToFree()) {
        final downgraded = premium.downgradeToFree();
        await _firestore.collection('Users').doc(_userId).set({
          'premium': downgraded.toMap(),
          'usage': UsageModel(
            fortuneSlots: List.generate(
              7,
              (i) => FortuneSlot(usedAt: DateTime.now(), isUsed: false),
            ),
            totalFortunes: 0,
            monthlyResetDate: DateTime.now(),
          ).toMap(),
        }, SetOptions(merge: true));
      }

      // Check if monthly reset needed
      final usageData = doc.data()?['usage'];
      if (usageData != null) {
        final usage = UsageModel.fromMap(usageData);
        if (usage.needsMonthlyReset()) {
          final resetUsage = usage.resetForNewMonth(premium.plan);
          await _firestore.collection('Users').doc(_userId).set({
            'usage': resetUsage.toMap(),
          }, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print('Error ensuring plan valid: $e');
    }
  }

  /// Check if user has active premium
  Future<bool> isPremiumUser() async {
    if (_userId == null) return false;

    try {
      final doc = await _firestore.collection('Users').doc(_userId).get();

      if (!doc.exists) return false;

      final premiumData = doc.data()?['premium'];
      if (premiumData == null) return false;

      final premium = PremiumModel.fromMap(premiumData);
      return premium.isActive();
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }

  /// Get premium details
  Future<PremiumModel?> getPremiumDetails() async {
    if (_userId == null) return null;

    try {
      final doc = await _firestore.collection('Users').doc(_userId).get();

      if (!doc.exists) return null;

      final premiumData = doc.data()?['premium'];
      if (premiumData == null) {
        return PremiumModel(isPremium: false);
      }

      return PremiumModel.fromMap(premiumData);
    } catch (e) {
      print('Error getting premium details: $e');
      return null;
    }
  }

  // ==================== USAGE MANAGEMENT ====================

  /// Check if user can read fortune (has available slot)
  Future<bool> canReadFortune() async {
    if (_userId == null) return false;

    try {
      await _ensurePlanValid();

      // Premium users have unlimited access
      final premium = await getPremiumDetails();
      if (premium?.isActive() ?? false) return true;

      // Get usage and check slots
      final usage = await _getUsageWithRefresh();
      if (usage == null) return true; // First time user

      // Check if any slot is available
      return usage.getAvailableSlotCount() > 0;
    } catch (e) {
      print('Error checking fortune availability: $e');
      return false;
    }
  }

  /// Get number of available fortune slots
  Future<int> getRemainingFortuneCount() async {
    if (_userId == null) return 0;

    try {
      await _ensurePlanValid();

      // Get premium details
      final premium = await getPremiumDetails();
      if (premium?.isActive() ?? false) {
        return premium!.getMonthlySlotCount();
      }

      // Get usage
      final usage = await _getUsageWithRefresh();
      if (usage == null) {
        return 7; // Default free plan
      }

      return usage.getAvailableSlotCount();
    } catch (e) {
      print('Error getting remaining count: $e');
      return 0;
    }
  }

  /// Get time until next slot becomes available
  Future<Duration?> getTimeUntilNextSlot() async {
    if (_userId == null) return null;

    try {
      await _ensurePlanValid();

      // Premium users don't need to wait
      final premium = await getPremiumDetails();
      if (premium?.isActive() ?? false) return Duration.zero;

      final usage = await _getUsage();
      if (usage == null) return null;

      final nextSlot = usage.getNextAvailableSlot();
      if (nextSlot == null) return null;

      return nextSlot.getRemainingTime();
    } catch (e) {
      print('Error getting time until next slot: $e');
      return null;
    }
  }

  // Emit current slot states to the stream (fetches `usedAt` from Firestore
  // and computes remaining time client-side). If user is premium, emits
  // slots with zero remaining time and isAvailable=true.
  Future<void> _emitCurrentSlotStates() async {
    try {
      await _ensurePlanValid();

      if (_userId == null) {
        // No user: emit free plan slots (7)
        final slots = List.generate(
          7,
          (i) => PremiumSlotState(
            index: i,
            isAvailable: true,
            remaining: Duration.zero,
            usedAt: null,
          ),
        );
        _slotController.add(slots);
        return;
      }

      final premium = await getPremiumDetails();
      if (premium?.isActive() ?? false) {
        // Premium user: unlimited slots
        final slotCount = premium!.getMonthlySlotCount();
        final slots = List.generate(
          slotCount,
          (i) => PremiumSlotState(
            index: i,
            isAvailable: true,
            remaining: Duration.zero,
            usedAt: null,
          ),
        );
        _slotController.add(slots);
        return;
      }

      // Free user: get actual slots from usage
      final usage = await _getUsage();
      if (usage == null) {
        final slots = List.generate(
          7,
          (i) => PremiumSlotState(
            index: i,
            isAvailable: true,
            remaining: Duration.zero,
            usedAt: null,
          ),
        );
        _slotController.add(slots);
        return;
      }

      final states = <PremiumSlotState>[];
      for (var i = 0; i < usage.fortuneSlots.length; i++) {
        final slot = usage.fortuneSlots[i];
        final available = slot.isAvailable();
        final remaining = slot.getRemainingTime();
        states.add(
          PremiumSlotState(
            index: i,
            isAvailable: available,
            remaining: remaining,
            usedAt: slot.usedAt,
          ),
        );
      }

      _slotController.add(states);
    } catch (e) {
      print('Error emitting slot states: $e');
    }
  }

  /// Get all slots with their availability status
  Future<List<Map<String, dynamic>>> getSlotDetails() async {
    if (_userId == null) return [];

    try {
      final usage = await _getUsageWithRefresh();
      if (usage == null) {
        // Return 2 empty slots
        return [
          {'isAvailable': true, 'remainingTime': Duration.zero},
          {'isAvailable': true, 'remainingTime': Duration.zero},
        ];
      }

      return usage.fortuneSlots.map((slot) {
        return {
          'isAvailable': slot.isAvailable(),
          'remainingTime': slot.getRemainingTime(),
          'usedAt': slot.usedAt,
        };
      }).toList();
    } catch (e) {
      print('Error getting slot details: $e');
      return [];
    }
  }

  /// Increment fortune usage (use a slot)
  Future<void> incrementFortuneUsage() async {
    if (_userId == null) return;

    try {
      await _ensurePlanValid();

      final docRef = _firestore.collection('Users').doc(_userId);
      final doc = await docRef.get();

      // Get premium plan to know slot count
      final premiumData = doc.data()?['premium'];
      final premium = premiumData != null
          ? PremiumModel.fromMap(premiumData)
          : PremiumModel(isPremium: false, plan: "free");

      UsageModel usage;
      if (doc.exists && doc.data()?['usage'] != null) {
        usage = UsageModel.fromMap(doc.data()!['usage']);
        // Refresh expired slots
        usage = usage.refreshSlots();
      } else {
        usage = UsageModel(
          fortuneSlots: List.generate(
            premium.getMonthlySlotCount(),
            (i) => FortuneSlot(usedAt: DateTime.now(), isUsed: false),
          ),
          totalFortunes: 0,
          monthlyResetDate: DateTime.now(),
        );
      }

      // Use a slot
      usage = usage.useSlot();

      // Save to Firestore
      await docRef.set({'usage': usage.toMap()}, SetOptions(merge: true));

      // Refresh stream
      await refreshSlotStates();
    } catch (e) {
      print('Error incrementing usage: $e');
    }
  }

  /// Get usage details
  Future<UsageModel?> _getUsage() async {
    if (_userId == null) return null;

    try {
      final doc = await _firestore.collection('Users').doc(_userId).get();

      if (!doc.exists || doc.data()?['usage'] == null) {
        return UsageModel(
          fortuneSlots: List.generate(
            7,
            (i) => FortuneSlot(usedAt: DateTime.now(), isUsed: false),
          ),
          totalFortunes: 0,
          monthlyResetDate: DateTime.now(),
        );
      }

      return UsageModel.fromMap(doc.data()!['usage']);
    } catch (e) {
      print('Error getting usage: $e');
      return null;
    }
  }

  /// Get usage and auto-refresh expired slots
  Future<UsageModel?> _getUsageWithRefresh() async {
    if (_userId == null) return null;

    try {
      final usage = await _getUsage();
      if (usage == null) return null;

      // Refresh slots that have expired
      final refreshed = usage.refreshSlots();

      // Save if anything changed
      if (refreshed.getAvailableSlotCount() != usage.getAvailableSlotCount()) {
        await _firestore.collection('Users').doc(_userId).set({
          'usage': refreshed.toMap(),
        }, SetOptions(merge: true));
      }

      return refreshed;
    } catch (e) {
      print('Error getting usage with refresh: $e');
      return null;
    }
  }

  // ==================== PREMIUM PURCHASE ====================

  /// Activate premium subscription
  Future<bool> activatePremium({
    required String plan, // "free" | "basic" | "premium" | "pro"
    required String platform, // "ios" | "android"
    bool autoRenew = true,
  }) async {
    if (_userId == null) return false;

    try {
      final now = DateTime.now();
      final expiryDate = now.add(Duration(days: 30)); // 30-day subscription

      final premium = PremiumModel(
        isPremium: plan != "free",
        purchaseDate: now,
        expiryDate: expiryDate,
        plan: plan,
        autoRenew: autoRenew,
        platform: platform,
      );

      // Create new slots based on plan
      final slotCount = premium.getMonthlySlotCount();
      final newUsage = UsageModel(
        fortuneSlots: List.generate(
          slotCount,
          (i) => FortuneSlot(usedAt: DateTime.now(), isUsed: false),
        ),
        totalFortunes: 0,
        monthlyResetDate: DateTime.now(),
      );

      await _firestore.collection('Users').doc(_userId).set({
        'premium': premium.toMap(),
        'usage': newUsage.toMap(),
      }, SetOptions(merge: true));

      await refreshSlotStates();
      return true;
    } catch (e) {
      print('Error activating premium: $e');
      return false;
    }
  }

  /// Cancel premium subscription
  Future<bool> cancelPremium() async {
    if (_userId == null) return false;

    try {
      final premium = PremiumModel(
        isPremium: false,
        plan: "free",
        autoRenew: false,
        expiryDate: DateTime.now().add(Duration(days: 30)),
      );

      // Reset to free slots
      final freeUsage = UsageModel(
        fortuneSlots: List.generate(
          7,
          (i) => FortuneSlot(usedAt: DateTime.now(), isUsed: false),
        ),
        totalFortunes: 0,
        monthlyResetDate: DateTime.now(),
      );

      await _firestore.collection('Users').doc(_userId).set({
        'premium': premium.toMap(),
        'usage': freeUsage.toMap(),
      }, SetOptions(merge: true));

      await refreshSlotStates();
      return true;
    } catch (e) {
      print('Error canceling premium: $e');
      return false;
    }
  }

  /// Restore premium purchase (for iOS)
  Future<bool> restorePremium() async {
    // TODO: Implement with in-app purchase verification
    // This will verify the purchase with App Store/Play Store
    return false;
  }

  // ==================== STATISTICS ====================

  /// Get total fortune count from Firestore
  Future<int> getTotalReadings() async {
    if (_userId == null) return 0;

    try {
      await _ensurePlanValid();
      final usage = await _getUsage();
      return usage?.totalFortunes ?? 0;
    } catch (e) {
      print('Error getting total readings: $e');
      return 0;
    }
  }

  /// Get remaining readings (available slots) from Firestore
  Future<int> getRemainingReadings() async {
    if (_userId == null) return 0;

    try {
      await _ensurePlanValid();
      final usage = await _getUsageWithRefresh();
      if (usage == null) return 7; // Default free plan
      return usage.getAvailableSlotCount();
    } catch (e) {
      print('Error getting remaining readings: $e');
      return 0;
    }
  }

  /// Get total fortune count
  Future<int> getTotalFortuneCount() async {
    if (_userId == null) return 0;

    try {
      final usage = await _getUsage();
      return usage?.totalFortunes ?? 0;
    } catch (e) {
      print('Error getting total fortune count: $e');
      return 0;
    }
  }

  /// Get used slots count
  Future<int> getUsedSlotsCount() async {
    if (_userId == null) return 0;

    try {
      await _ensurePlanValid();

      final usage = await _getUsageWithRefresh();
      if (usage == null) return 0;

      return usage.fortuneSlots.length - usage.getAvailableSlotCount();
    } catch (e) {
      print('Error getting used slots count: $e');
      return 0;
    }
  }
}

/// Lightweight DTO representing the availability and remaining time for a slot.
class PremiumSlotState {
  final int index;
  final bool isAvailable;
  final Duration remaining;
  final DateTime? usedAt;

  PremiumSlotState({
    required this.index,
    required this.isAvailable,
    required this.remaining,
    required this.usedAt,
  });

  String remainingFormatted() {
    final d = remaining;
    if (d == Duration.zero) return '0s';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}
