import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  late String uid;
  @HiveField(1)
  late String email;
  @HiveField(2)
  late String? displayName;
  @HiveField(3)
  late String? phoneNumber;
  @HiveField(4)
  late bool? isPremium;
  @HiveField(5)
  late DateTime? premiumExpiryDate;
  @HiveField(6)
  late int? totalReadings;
  @HiveField(7)
  late int? remaningReadings;
  @HiveField(8)
  late DateTime? createdAt;
  @HiveField(9)
  late DateTime? updatedAt;
  @HiveField(10)
  late String? profilePictureUrl;
  @HiveField(11)
  late String? gender;
  @HiveField(12)
  late String? maritalStatus;
  @HiveField(13)
  late int? age;
  @HiveField(14)
  late String? plan; // "free" | "basic" | "premium" | "pro"

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.isPremium = false,
    this.premiumExpiryDate,
    this.totalReadings = 0,
    this.remaningReadings = 1,
    this.createdAt,
    this.updatedAt,
    this.profilePictureUrl,
    this.gender,
    this.maritalStatus,
    this.age,
    this.plan = "free",
  });
}
