import 'package:cloud_firestore/cloud_firestore.dart';

class FortuneSlot {
  final DateTime usedAt;
  final bool isUsed;

  FortuneSlot({
    required this.usedAt,
    required this.isUsed,
  });

  factory FortuneSlot.fromMap(Map<String, dynamic> map) {
    return FortuneSlot(
      usedAt: (map['usedAt'] as Timestamp).toDate(),
      isUsed: map['isUsed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usedAt': Timestamp.fromDate(usedAt),
      'isUsed': isUsed,
    };
  }

  // Check if this slot is available (1 week passed since usage)
  bool isAvailable() {
    if (!isUsed) return true;
    
    final now = DateTime.now();
    final daysSinceUsed = now.difference(usedAt).inDays;
    
    return daysSinceUsed >= 7; // 7 days = 1 week
  }

  // Get remaining time until slot becomes available
  Duration getRemainingTime() {
    if (!isUsed) return Duration.zero;
    
    final now = DateTime.now();
    final availableAt = usedAt.add(Duration(days: 7));
    
    if (now.isAfter(availableAt)) {
      return Duration.zero;
    }
    
    return availableAt.difference(now);
  }
}