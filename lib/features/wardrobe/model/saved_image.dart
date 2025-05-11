import 'package:hive/hive.dart';

part 'saved_image.g.dart';

@HiveType(typeId: 0)
class SavedImage extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final List<String> tags;

  SavedImage({
    required this.name,
    required this.imagePath,
    required this.tags,
  });
}
