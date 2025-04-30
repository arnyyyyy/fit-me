import 'package:flutter/material.dart';
import '../../screens/select_image_screen.dart';
import '../model/model.dart';
import '../message/message.dart';
import '../model/saved_image.dart';

abstract class Effect {}

class NavigationEffect extends Effect {
  final Widget destination;

  NavigationEffect(this.destination);
}

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
      final filtered = _filterClothes(images, model.searchQuery);
      return UpdateResult(model.copyWith(
        isLoading: false,
        allImages: images,
        filteredImages: filtered,
      ));

    case ImagesLoadError(:final message):
      return UpdateResult(model.copyWith(
        isLoading: false,
        errorMessage: message,
      ));

    case ToggleSearch(:final isSearching):
      final query = isSearching ? model.searchQuery : '';
      final filtered = isSearching ? model.filteredClothes : model.allImages;
      return UpdateResult(model.copyWith(
        isSearching: isSearching,
        searchQuery: query,
        filteredImages: filtered,
      ));

    case SearchQueryChanged(:final query):
      final filtered = _filterClothes(model.allImages, query);
      return UpdateResult(model.copyWith(
        searchQuery: query,
        filteredImages: filtered,
      ));

    case AddImage(:final image):
      final updatedAll = List<SavedImage>.from(model.allImages)..add(image);
      final filtered = _filterClothes(updatedAll, model.searchQuery);
      return UpdateResult(model.copyWith(
        allImages: updatedAll,
        filteredImages: filtered,
      ));

    case NavigateToAddImage():
      return UpdateResult(model, {NavigationEffect(const SelectImageScreen())});
  }

  return UpdateResult(model);
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
