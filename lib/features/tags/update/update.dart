import '../model/model.dart';
import '../message/message.dart';
import '../effect/effect.dart';

class UpdateResult {
  final TagsModel model;
  final List<TagsEffect>? effects;

  const UpdateResult(this.model, {this.effects});
}

UpdateResult update(TagsModel model, TagsMessage message) {
  switch (message) {
    case LoadTags():
      return UpdateResult(
        model.copyWith(isLoadingTags: true, clearError: true),
        effects: [LoadTagsEffect()],
      );

    case TagsLoaded(:final tags):
      return UpdateResult(model.copyWith(
        availableTags: tags,
        isLoadingTags: false,
      ));

    case TagsLoadError(:final message):
      return UpdateResult(model.copyWith(
        errorMessage: message,
        isLoadingTags: false,
      ));

    case AddTag(:final tag):
      final trimmed = tag.trim();
      if (trimmed.isEmpty || model.selectedTags.contains(trimmed)) {
        return UpdateResult(model);
      }
      final updatedTags = [...model.selectedTags, trimmed];
      return UpdateResult(
        model.copyWith(
          selectedTags: updatedTags,
          clearError: true,
        ),
        effects: [TagsUpdatedCallbackEffect(updatedTags)],
      );

    case RemoveTag(:final tag):
      final updatedTags = [...model.selectedTags]..remove(tag);
      return UpdateResult(
        model.copyWith(selectedTags: updatedTags),
        effects: [TagsUpdatedCallbackEffect(updatedTags)],
      );

    case ClearTagInput():
      model.tagInputController?.clear();
      return UpdateResult(model);

    case SetInitialTags(:final tags):
      return UpdateResult(model.copyWith(
        selectedTags: tags,
        clearError: true,
      ));

    case TagsChanged():
      return UpdateResult(model);
  }

  return UpdateResult(model);
}
