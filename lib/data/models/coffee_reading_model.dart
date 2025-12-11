import 'package:hive/hive.dart';

part 'coffee_reading_model.g.dart';

@HiveType(typeId: 0)
class CoffeeReadingModel extends HiveObject {
  @HiveField(0)
  late List<String> imagePaths;

  @HiveField(1)
  late String reading;

  @HiveField(2)
  late DateTime createdAt;

  @HiveField(3)
  late String? notes;

  CoffeeReadingModel({
    required this.imagePaths,
    required this.reading,
    required this.createdAt,
    this.notes,
  });
}
