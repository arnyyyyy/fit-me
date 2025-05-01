import 'package:flutter/material.dart';
import '../../collage_constructor/view/collage_constructor_screen.dart';
import '../model/model.dart';
import '../message/message.dart';
import '../model/saved_collage.dart';

abstract class Effect {}

class NavigationEffect extends Effect {
  final Widget destination;

  NavigationEffect(this.destination);
}

class UpdateResult {
  final CollagesModel model;
  final Set<Effect>? effects;

  UpdateResult(this.model, [this.effects]);
}

UpdateResult update(CollagesModel model, Message message) {
  switch (message) {
    case LoadCollages():
      return UpdateResult(model.copyWith(isLoading: true));

    case CollagesLoaded(:final collages):
      final filtered = _filterCollages(collages, model.searchQuery);
      return UpdateResult(model.copyWith(
        isLoading: false,
        allCollages: collages,
        filteredCollages: filtered,
      ));

    case CollagesLoadError(:final message):
      return UpdateResult(model.copyWith(
        isLoading: false,
        errorMessage: message,
      ));

    case ToggleSearch(:final isSearching):
      final query = isSearching ? model.searchQuery : '';
      final filtered = isSearching ? model.filteredCollages : model.allCollages;
      return UpdateResult(model.copyWith(
        isSearching: isSearching,
        searchQuery: query,
        filteredCollages: filtered,
      ));

    case SearchQueryChanged(:final query):
      final filtered = _filterCollages(model.allCollages, query);
      return UpdateResult(model.copyWith(
        searchQuery: query,
        filteredCollages: filtered,
      ));

    case AddCollage(:final collage):
      final updatedAll = List<SavedCollage>.from(model.allCollages)..add(collage);
      final filtered = _filterCollages(updatedAll, model.searchQuery);
      return UpdateResult(model.copyWith(
        allCollages: updatedAll,
        filteredCollages: filtered,
      ));

    case NavigateToCreateCollage():
      return UpdateResult(model, {NavigationEffect(const CollageConstructorScreen())});
  }

  return UpdateResult(model);
}

List<SavedCollage> _filterCollages(List<SavedCollage> collages, String query) {
  if (query.isEmpty) {
    return collages;
  }

  final lowercaseQuery = query.toLowerCase();
  return collages.where((collage) {
    final name = collage.name.toLowerCase();
    if (name.contains(lowercaseQuery)) {
      return true;
    }

    return collage.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }).toList();
}