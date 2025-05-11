import 'package:fit_me/features/collages/model/saved_collage.dart';

class EditCollageModel {
  final SavedCollage originalItem;
  final String name;
  final List<String> tags;
  final bool isSaving;
  final bool hasChanges;

  EditCollageModel({
    required this.originalItem,
    String? name,
    List<String>? tags,
    this.isSaving = false,
    this.hasChanges = false,
  })  : name = name ?? originalItem.name,
        tags = tags ?? List.of(originalItem.tags);

  EditCollageModel copyWith({
    SavedCollage? originalItem,
    String? name,
    List<String>? tags,
    bool? isSaving,
    bool? hasChanges,
  }) {
    return EditCollageModel(
      originalItem: originalItem ?? this.originalItem,
      name: name ?? this.name,
      tags: tags ?? this.tags,
      isSaving: isSaving ?? this.isSaving,
      hasChanges: hasChanges ?? this.hasChanges,
    );
  }

  bool get isValid => name.trim().isNotEmpty;
}
