import 'package:fit_me/features/wardrobe/model/saved_image.dart';

class EditClothesModel {
  final SavedImage originalItem;
  final String name;
  final String description;
  final List<String> tags;
  final bool isSaving;
  final bool hasChanges;

  EditClothesModel({
    required this.originalItem,
    String? name,
    String? description,
    List<String>? tags,
    this.isSaving = false,
    this.hasChanges = false,
  })  : name = name ?? originalItem.name,
        description = description ?? originalItem.description,
        tags = tags ?? List.of(originalItem.tags);

  EditClothesModel copyWith({
    SavedImage? originalItem,
    String? name,
    String? description,
    List<String>? tags,
    bool? isSaving,
    bool? hasChanges,
  }) {
    return EditClothesModel(
      originalItem: originalItem ?? this.originalItem,
      name: name ?? this.name,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      isSaving: isSaving ?? this.isSaving,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  bool get isValid => name.trim().isNotEmpty;
}
