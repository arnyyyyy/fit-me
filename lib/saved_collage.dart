import 'package:hive/hive.dart';

part 'saved_collage.g.dart';

@HiveType(typeId: 2)
class SavedCollage extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final List<String> tags;

  SavedCollage({
    required this.name,
    required this.imagePath,
    required this.tags,
  });
}
