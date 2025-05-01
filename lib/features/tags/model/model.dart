import 'package:flutter/material.dart';

@immutable
class TagsModel {
  final List<String> availableTags;
  final List<String> selectedTags;
  final String? errorMessage;
  final bool isLoadingTags;
  final TextEditingController? tagInputController;

  const TagsModel({
    this.availableTags = const [],
    this.selectedTags = const [],
    this.errorMessage,
    this.isLoadingTags = false,
    this.tagInputController,
  });

  TagsModel copyWith({
    List<String>? availableTags,
    List<String>? selectedTags,
    String? errorMessage,
    bool? isLoadingTags,
    TextEditingController? tagInputController,
    bool clearError = false,
  }) {
    return TagsModel(
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoadingTags: isLoadingTags ?? this.isLoadingTags,
      tagInputController: tagInputController ?? this.tagInputController,
    );
  }
}
