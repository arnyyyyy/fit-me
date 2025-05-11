import 'package:flutter/material.dart';
import '../../collage_constructor/view/collage_constructor_screen.dart';
import '../../edit_collage/view/edit_collage_screen.dart';
import '../model/model.dart';
import '../message/message.dart';
import '../model/saved_collage.dart';

abstract class Effect {}

class NavigationEffect extends Effect {
  final Widget destination;

  NavigationEffect(this.destination);
}

class ConfirmDeleteEffect extends Effect {
  final SavedCollage item;

  ConfirmDeleteEffect(this.item);
}

class ReloadDataEffect extends Effect {}

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
      final availableTags = _extractAllTags(collages);
      final filtered =
          _applyAllFilters(collages, model.searchQuery, model.selectedTags);
      return UpdateResult(model.copyWith(
        isLoading: false,
        allCollages: collages,
        filteredCollages: filtered,
        availableTags: availableTags,
      ));

    case CollagesLoadError(:final message):
      return UpdateResult(model.copyWith(
        isLoading: false,
        errorMessage: message,
      ));

    case ToggleSearch(:final isSearching):
      final query = isSearching ? model.searchQuery : '';
      final filtered =
          _applyAllFilters(model.allCollages, query, model.selectedTags);
      return UpdateResult(model.copyWith(
        isSearching: isSearching,
        searchQuery: query,
        filteredCollages: filtered,
      ));

    case SearchQueryChanged(:final query):
      final filtered =
          _applyAllFilters(model.allCollages, query, model.selectedTags);
      return UpdateResult(model.copyWith(
        searchQuery: query,
        filteredCollages: filtered,
      ));

    case AddCollage(:final collage):
      final updatedAll = List<SavedCollage>.from(model.allCollages)
        ..add(collage);
      final allTags = _extractAllTags(updatedAll);
      final filtered =
          _applyAllFilters(updatedAll, model.searchQuery, model.selectedTags);
      return UpdateResult(model.copyWith(
        allCollages: updatedAll,
        filteredCollages: filtered,
        availableTags: allTags,
      ));

    case RemoveCollage(:final collage):
      final updatedAll =
          model.allCollages.where((c) => c.key != collage.key).toList();
      final allTags = _extractAllTags(updatedAll);
      final filtered =
          _applyAllFilters(updatedAll, model.searchQuery, model.selectedTags);
      return UpdateResult(model.copyWith(
        allCollages: updatedAll,
        filteredCollages: filtered,
        availableTags: allTags,
      ));

    case NavigateToCreateCollage():
      return UpdateResult(
          model, {NavigationEffect(const CollageConstructorScreen())});

    case ToggleTagFilter(:final isVisible):
      return UpdateResult(model.copyWith(
        isTagFilterVisible: isVisible,
      ));

    case LoadAvailableTags():
      final allTags = _extractAllTags(model.allCollages);
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
          _applyAllFilters(model.allCollages, model.searchQuery, updatedTags);
      return UpdateResult(model.copyWith(
        selectedTags: updatedTags,
        filteredCollages: filtered,
      ));

    case ClearTagFilters():
      final filtered = _filterCollages(model.allCollages, model.searchQuery);
      return UpdateResult(model.copyWith(
        selectedTags: [],
        filteredCollages: filtered,
      ));

    case EditCollage(:final collage):
      return UpdateResult(
          model, {NavigationEffect(EditCollageScreen(item: collage))});

    case ShowDeleteConfirmation(:final collage):
      return UpdateResult(model, {ConfirmDeleteEffect(collage)});
  }

  return UpdateResult(model);
}

List<String> _extractAllTags(List<SavedCollage> collages) {
  final allTags = <String>{};
  for (final collage in collages) {
    allTags.addAll(collage.tags);
  }
  return allTags.toList()..sort();
}

List<SavedCollage> _applyAllFilters(List<SavedCollage> collages,
    String searchQuery, List<String> selectedTags) {
  var filtered = _filterCollages(collages, searchQuery);

  if (selectedTags.isNotEmpty) {
    filtered = filtered.where((collage) {
      return selectedTags.every((tag) => collage.tags.contains(tag));
    }).toList();
  }

  return filtered;
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

    return collage.tags
        .any((tag) => tag.toLowerCase().contains(lowercaseQuery));
  }).toList();
}
