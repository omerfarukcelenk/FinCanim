// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coffee_reading_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CoffeeReadingModelAdapter extends TypeAdapter<CoffeeReadingModel> {
  @override
  final int typeId = 0;

  @override
  CoffeeReadingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoffeeReadingModel(
      imagePaths: (fields[0] as List).cast<String>(),
      reading: fields[1] as String,
      createdAt: fields[2] as DateTime,
      notes: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CoffeeReadingModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.imagePaths)
      ..writeByte(1)
      ..write(obj.reading)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoffeeReadingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
