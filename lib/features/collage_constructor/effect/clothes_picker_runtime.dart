import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/base_runtime.dart';
import '../message/clothes_picker_tag_messages.dart';

class ClothesPickerRuntime extends BaseRuntime<TagMessage> {
  final BuildContext context;
  final WidgetRef ref;
  final dynamic state;

  ClothesPickerRuntime(this.context, this.ref, this.state);

  @override
  void dispatch(TagMessage message) {
    if (message is TagSelected) {
      _handleTagSelection(message.tag, message.isSelected);
    } else if (message is ClearTagFilters) {
      _handleClearFilters();
    } else if (message is SearchQueryChanged) {
      state.filterBySearchQuery(message.query);
    } else if (message is ToggleSearch) {
      state.toggleSearch(message.isSearching);
    } else if (message is ToggleTagFilter) {
      state.toggleTagFilter(message.isVisible);
    } else if (message is LoadAvailableTags) {
      state.loadTags();
    }
  }

  void _handleTagSelection(String tag, bool isSelected) {
    if (isSelected) {
      if (!state.selectedTags.contains(tag)) {
        state.addTag(tag);
      }
    } else {
      state.removeTag(tag);
    }
  }

  void _handleClearFilters() {
    state.clearTags();
  }
}
