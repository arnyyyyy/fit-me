import 'package:flutter/material.dart';
import '../../clothes_constructor/view/select_image_screen.dart';
import '../../edit_clothes/view/edit_clothes_screen.dart';
import '../model/model.dart';
import '../message/message.dart';
import '../model/saved_image.dart';

abstract class Effect {}

class NavigationEffect extends Effect {
  final Widget destination;

  NavigationEffect(this.destination);
}

class ConfirmDeleteEffect extends Effect {
  final SavedImage item;

  ConfirmDeleteEffect(this.item);
}

class ReloadDataEffect extends Effect {}

class UpdateResult {
  final ClothesModel model;
  final Set<Effect>? effects;

  UpdateResult(this.model, [this.effects]);
}

UpdateResult update(ClothesModel model, Message message) {
  switch (message) {
    case LoadImages():
      return UpdateResult(model.copyWith(isLoading: true));

    case ImagesLoaded(:final images):
      final availableTags = _extractAllTags(images);
      final filtered =
          _applyAllFilters(images, model.searchQuery, model.selectedTags);
      return UpdateResult(model.copyWith(
        isLoading: false,
        allImages: images,
        filteredImages: filtered,
        availableTags: availableTags,
      ));

    case ImagesLoadError(:final message):
      return UpdateResult(model.copyWith(
        isLoading: false,
        errorMessage: message,
      ));

    case ToggleSearch(:final isSearching):
      final query = isSearching ? model.searchQuery : '';
      final filtered =
          _applyAllFilters(model.allImages, query, model.selectedTags);
      return UpdateResult(model.copyWith(
        isSearching: isSearching,
        searchQuery: query,
        filteredImages: filtered,
      ));

    case SearchQueryChanged(:final query):
      final filtered =
          _applyAllFilters(model.allImages, query, model.selectedTags);
      return UpdateResult(model.copyWith(
        searchQuery: query,
        filteredImages: filtered,
      ));

    case AddImage(:final image):
      final updatedAll = List<SavedImage>.from(model.allImages)..add(image);
      final allTags = _extractAllTags(updatedAll);
      final filtered =
          _applyAllFilters(updatedAll, model.searchQuery, model.selectedTags);
      return UpdateResult(model.copyWith(
        allImages: updatedAll,
        filteredImages: filtered,
        availableTags: allTags,
      ));

    case RemoveImage(:final image):
      final updatedAll =
          model.allImages.where((img) => img.key != image.key).toList();
      final allTags = _extractAllTags(updatedAll);
      final filtered =
          _applyAllFilters(updatedAll, model.searchQuery, model.selectedTags);
      return UpdateResult(model.copyWith(
        allImages: updatedAll,
        filteredImages: filtered,
        availableTags: allTags,
      ));

    case NavigateToAddImage():
      return UpdateResult(model, {NavigationEffect(const SelectImageScreen())});

    case ToggleTagFilter(:final isVisible):
      return UpdateResult(model.copyWith(
        isTagFilterVisible: isVisible,
      ));

    case LoadAvailableTags():
      final allTags = _extractAllTags(model.allImages);
      return UpdateResult(model.copyWith(
        availableTags: allTags,
      ));

    case TagsLoaded(:final tags):
      return UpdateResult(model.copyWith(
        availableTags: tags,
      ));

    case TagSelected(:final tag, :final isSelected):
      List<String> updatedTags;
      if (isSelected) {
        updatedTags = List<String>.from(model.selectedTags)..add(tag);
      } else {
        updatedTags = model.selectedTags.where((t) => t != tag).toList();
      }

      final filtered =
          _applyAllFilters(model.allImages, model.searchQuery, updatedTags);
      return UpdateResult(model.copyWith(
        selectedTags: updatedTags,
        filteredImages: filtered,
      ));

    case ClearTagFilters():
      final filtered = _filterClothes(model.allImages, model.searchQuery);
      return UpdateResult(model.copyWith(
        selectedTags: [],
        filteredImages: filtered,
      ));

    case EditImage(:final image):
      return UpdateResult(
          model, {NavigationEffect(EditClothesScreen(item: image))});

    case ShowDeleteConfirmation(:final image):
      return UpdateResult(model, {ConfirmDeleteEffect(image)});
  }

  return UpdateResult(model);
}

List<String> _extractAllTags(List<SavedImage> images) {
  final allTags = <String>{};
  for (final image in images) {
    allTags.addAll(image.tags);
  }
  return allTags.toList()..sort();
}

List<SavedImage> _applyAllFilters(
    List<SavedImage> images, String searchQuery, List<String> selectedTags) {
  var filtered = _filterClothes(images, searchQuery);

  if (selectedTags.isNotEmpty) {
    filtered = filtered.where((image) {
      return selectedTags.every((tag) => image.tags.contains(tag));
    }).toList();
  }

  return filtered;
}

List<SavedImage> _filterClothes(List<SavedImage> images, String query) {
  if (query.isEmpty) {
    return images;
  }

  final lowercaseQuery = query.toLowerCase();
  return images.where((image) {
    final name = image.name.toLowerCase();
    if (name.contains(lowercaseQuery)) {
      return true;
    }

    return image.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }).toList();
}
