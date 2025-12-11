import 'package:cloud_firestore/cloud_firestore.dart';

class PremiumModel {
  final bool isPremium;
  final DateTime? purchaseDate;
  final DateTime? expiryDate;
  final String plan; // "free" | "basic" | "premium" | "pro"
  final bool autoRenew;
  final String? platform; // "ios" | "android"

  PremiumModel({
    required this.isPremium,
    this.purchaseDate,
    this.expiryDate,
    this.plan = "free",
    this.autoRenew = false,
    this.platform,
  });

  // Convert from Firestore
  factory PremiumModel.fromMap(Map<String, dynamic> map) {
    return PremiumModel(
      isPremium: map['isPremium'] ?? false,
      purchaseDate: map['purchaseDate'] != null
          ? (map['purchaseDate'] as Timestamp).toDate()
          : null,
      expiryDate: map['expiryDate'] != null
          ? (map['expiryDate'] as Timestamp).toDate()
          : null,
      plan: map['plan'] ?? "free",
      autoRenew: map['autoRenew'] ?? false,
      platform: map['platform'],
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      'isPremium': isPremium,
      'purchaseDate': purchaseDate != null
          ? Timestamp.fromDate(purchaseDate!)
          : null,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'plan': plan,
      'autoRenew': autoRenew,
      'platform': platform,
    };
  }

  // Check if premium is still valid
  bool isActive() {
    if (!isPremium) return false;
    if (expiryDate == null) return true; // Lifetime premium
    return DateTime.now().isBefore(expiryDate!);
  }

  // Check if subscription has expired
  bool isExpired() {
    if (expiryDate == null) return false; // No expiry = lifetime
    return DateTime.now().isAfter(expiryDate!);
  }

  // Check if should downgrade to free (expired and not auto-renewing)
  bool shouldDowngradeToFree() {
    return plan != "free" && isExpired() && !autoRenew;
  }

  // Get monthly slot count for this plan
  int getMonthlySlotCount() {
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

  // Copy with
  PremiumModel copyWith({
    bool? isPremium,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? plan,
    bool? autoRenew,
    String? platform,
  }) {
    return PremiumModel(
      isPremium: isPremium ?? this.isPremium,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      plan: plan ?? this.plan,
      autoRenew: autoRenew ?? this.autoRenew,
      platform: platform ?? this.platform,
    );
  }

  // Downgrade to free plan
  PremiumModel downgradeToFree() {
    return PremiumModel(
      isPremium: false,
      purchaseDate: purchaseDate,
      expiryDate: DateTime.now().add(Duration(days: 30)),
      plan: "free",
      autoRenew: false,
      platform: platform,
    );
  }
}
