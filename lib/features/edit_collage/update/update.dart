import 'package:fit_me/features/collages/model/saved_collage.dart';
import 'package:fit_me/features/edit_collage/message/message.dart';
import 'package:fit_me/features/edit_collage/model/model.dart';

typedef Effect = Future<EditCollageMessage> Function();

(EditCollageModel, Effect?) update(
  EditCollageModel model,
  EditCollageMessage message,
) {
  return switch (message) {
    EditCollageInit() => (model, null),
    EditCollageUpdateName(name: final name) => (
        model.copyWith(
          name: name,
          hasChanges: name != model.originalItem.name,
        ),
        null,
      ),
    EditCollageAddTag(tag: final tag) => _addTag(model, tag),
    EditCollageRemoveTag(tag: final tag) => _removeTag(model, tag),
    EditCollageSave() => (
        model.copyWith(isSaving: true),
        () => _saveChanges(model),
      ),
    EditCollageCancel() => (model, null),
    EditCollageCompleted() => (
        model.copyWith(isSaving: false),
        null,
      ),
  };
}

(EditCollageModel, Effect?) _addTag(EditCollageModel model, String tag) {
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

(EditCollageModel, Effect?) _removeTag(EditCollageModel model, String tag) {
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

Future<EditCollageMessage> _saveChanges(EditCollageModel model) async {
  try {
    final updatedCollage = SavedCollage(
      name: model.name,
      imagePath: model.originalItem.imagePath,
      tags: List.from(model.tags),
    );

    final key = model.originalItem.key;

    if (model.originalItem.box == null) {
      return EditCollageCompleted(success: false);
    }

    await model.originalItem.box!.put(key, updatedCollage);

    return EditCollageCompleted(success: true);
  } catch (e) {
    return EditCollageCompleted(success: false);
  }
}
