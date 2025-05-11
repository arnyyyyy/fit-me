import 'package:fit_me/features/edit_clothes/message/message.dart';
import 'package:fit_me/features/edit_clothes/model/model.dart';
import 'package:fit_me/features/wardrobe/model/saved_image.dart';

typedef Effect = Future<EditClothesMessage> Function();

(EditClothesModel, Effect?) update(
  EditClothesModel model,
  EditClothesMessage message,
) {
  return switch (message) {
    EditClothesInit() => (model, null),
    EditClothesUpdateName(name: final name) => (
        model.copyWith(
          name: name,
          hasChanges: name != model.originalItem.name,
        ),
        null,
      ),
    EditClothesAddTag(tag: final tag) => _addTag(model, tag),
    EditClothesRemoveTag(tag: final tag) => _removeTag(model, tag),
    EditClothesSave() => (
        model.copyWith(isSaving: true),
        () => _saveChanges(model),
      ),
    EditClothesCancel() => (model, null),
    EditClothesCompleted() => (
        model.copyWith(isSaving: false),
        null,
      ),
  };
}

(EditClothesModel, Effect?) _addTag(EditClothesModel model, String tag) {
  if (tag.isEmpty || model.tags.contains(tag)) {
    return (model, null);
  }

  final newTags = List<String>.from(model.tags)..add(tag);
  return (
    model.copyWith(
      tags: newTags,
      hasChanges: _checkHasChanges(model.originalItem.tags, newTags) ||
          model.name != model.originalItem.name,
    ),
    null,
  );
}

(EditClothesModel, Effect?) _removeTag(EditClothesModel model, String tag) {
  final newTags = List<String>.from(model.tags)..remove(tag);
  return (
    model.copyWith(
      tags: newTags,
      hasChanges: _checkHasChanges(model.originalItem.tags, newTags) ||
          model.name != model.originalItem.name,
    ),
    null,
  );
}

bool _checkHasChanges(List<String> originalTags, List<String> newTags) {
  if (originalTags.length != newTags.length) {
    return true;
  }

  final sortedOriginal = List<String>.from(originalTags)..sort();
  final sortedNew = List<String>.from(newTags)..sort();

  for (var i = 0; i < sortedOriginal.length; i++) {
    if (sortedOriginal[i] != sortedNew[i]) {
      return true;
    }
  }

  return false;
}

Future<EditClothesMessage> _saveChanges(EditClothesModel model) async {
  try {
    final updatedImage = SavedImage(
      name: model.name,
      imagePath: model.originalItem.imagePath,
      tags: List.from(model.tags),
    );

    final key = model.originalItem.key;

    if (model.originalItem.box == null) {
      return EditClothesCompleted(success: false);
    }

    await model.originalItem.box!.put(key, updatedImage);

    return EditClothesCompleted(success: true);
  } catch (e) {
    return EditClothesCompleted(success: false);
  }
}
