// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      uid: fields[0] as String,
      email: fields[1] as String,
      displayName: fields[2] as String?,
      phoneNumber: fields[3] as String?,
      isPremium: fields[4] as bool?,
      premiumExpiryDate: fields[5] as DateTime?,
      totalReadings: fields[6] as int?,
      remaningReadings: fields[7] as int?,
      createdAt: fields[8] as DateTime?,
      updatedAt: fields[9] as DateTime?,
      profilePictureUrl: fields[10] as String?,
      gender: fields[11] as String?,
      maritalStatus: fields[12] as String?,
      age: fields[13] as int?,
      plan: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.isPremium)
      ..writeByte(5)
      ..write(obj.premiumExpiryDate)
      ..writeByte(6)
      ..write(obj.totalReadings)
      ..writeByte(7)
      ..write(obj.remaningReadings)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt)
      ..writeByte(10)
      ..write(obj.profilePictureUrl)
      ..writeByte(11)
      ..write(obj.gender)
      ..writeByte(12)
      ..write(obj.maritalStatus)
      ..writeByte(13)
      ..write(obj.age)
      ..writeByte(14)
      ..write(obj.plan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
