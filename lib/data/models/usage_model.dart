import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcim_benim/data/models/fortune_slot_model.dart';

class UsageModel {
  final List<FortuneSlot> fortuneSlots;
  final int totalFortunes;
  final DateTime monthlyResetDate; // Last monthly reset date

  UsageModel({
    required this.fortuneSlots,
    required this.totalFortunes,
    DateTime? monthlyResetDate,
  }) : monthlyResetDate = monthlyResetDate ?? DateTime.now();

  factory UsageModel.fromMap(Map<String, dynamic> map) {
    List<FortuneSlot> slots = [];

    if (map['fortuneSlots'] != null) {
      final slotsList = map['fortuneSlots'] as List;
      slots = slotsList
          .map((slot) => FortuneSlot.fromMap(slot as Map<String, dynamic>))
          .toList();
    } else {
      // Initialize with 7 available slots (free plan default)
      slots = List.generate(
        7,
        (i) => FortuneSlot(usedAt: DateTime.now(), isUsed: false),
      );
    }

    final resetDate = map['monthlyResetDate'] != null
        ? (map['monthlyResetDate'] as Timestamp).toDate()
        : DateTime.now();

    return UsageModel(
      fortuneSlots: slots,
      totalFortunes: map['totalFortunes'] ?? 0,
      monthlyResetDate: resetDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fortuneSlots': fortuneSlots.map((slot) => slot.toMap()).toList(),
      'totalFortunes': totalFortunes,
      'monthlyResetDate': Timestamp.fromDate(monthlyResetDate),
    };
  }

  // Get count of available slots
  int getAvailableSlotCount() {
    return fortuneSlots.where((slot) => slot.isAvailable()).length;
  }

  // Get slot count for a specific plan
  int getSlotCountForPlan(String plan) {
    switch (plan) {
      case "free":
        return 7;
      case "basic":
        return 14;
      case "premium":
        return 30;
      case "pro":
        return 999; // Unlimited
      default:
        return 7;
    }
  }

  // Check if monthly reset is needed (30+ days since last reset)
  bool needsMonthlyReset() {
    final now = DateTime.now();
    final daysSinceReset = now.difference(monthlyResetDate).inDays;
    return daysSinceReset >= 30;
  }

  // Create new monthly slots for a plan
  UsageModel resetForNewMonth(String plan) {
    final slotCount = getSlotCountForPlan(plan);
    final newSlots = List.generate(
      slotCount,
      (i) => FortuneSlot(usedAt: DateTime.now(), isUsed: false),
    );

    return UsageModel(
      fortuneSlots: newSlots,
      totalFortunes: totalFortunes, // Keep total count
      monthlyResetDate: DateTime.now(),
    );
  }

  // Get next slot that will become available
  FortuneSlot? getNextAvailableSlot() {
    final usedSlots = fortuneSlots
        .where((slot) => slot.isUsed && !slot.isAvailable())
        .toList();

    if (usedSlots.isEmpty) return null;

    // Sort by usedAt (earliest first)
    usedSlots.sort((a, b) => a.usedAt.compareTo(b.usedAt));

    return usedSlots.first;
  }

  // Use a fortune slot
  UsageModel useSlot() {
    // Find first available slot
    final availableIndex = fortuneSlots.indexWhere(
      (slot) => slot.isAvailable(),
    );

    if (availableIndex == -1) {
      return this; // No available slots
    }

    final updatedSlots = List<FortuneSlot>.from(fortuneSlots);
    updatedSlots[availableIndex] = FortuneSlot(
      usedAt: DateTime.now(),
      isUsed: true,
    );

    return UsageModel(
      fortuneSlots: updatedSlots,
      totalFortunes: totalFortunes + 1,
    );
  }

  // Refresh slots (check and reset available ones)
  UsageModel refreshSlots() {
    final updatedSlots = fortuneSlots.map((slot) {
      if (slot.isUsed && slot.isAvailable()) {
        // Reset this slot
        return FortuneSlot(usedAt: DateTime.now(), isUsed: false);
      }
      return slot;
    }).toList();

    return UsageModel(fortuneSlots: updatedSlots, totalFortunes: totalFortunes);
  }

  UsageModel copyWith({
    List<FortuneSlot>? fortuneSlots,
    int? totalFortunes,
    DateTime? monthlyResetDate,
  }) {
    return UsageModel(
      fortuneSlots: fortuneSlots ?? this.fortuneSlots,
      totalFortunes: totalFortunes ?? this.totalFortunes,
      monthlyResetDate: monthlyResetDate ?? this.monthlyResetDate,
    );
  }
}
