class ClothesPickerModel {
  final List<String> availableTags;
  final List<String> selectedTags;
  final bool isSearching;
  final String searchQuery;
  final bool isTagFilterVisible;

  ClothesPickerModel({
    required this.availableTags,
    required this.selectedTags,
    this.isSearching = false,
    this.searchQuery = '',
    this.isTagFilterVisible = false,
  });

  ClothesPickerModel copyWith({
    List<String>? availableTags,
    List<String>? selectedTags,
    bool? isSearching,
    String? searchQuery,
    bool? isTagFilterVisible,
  }) {
    return ClothesPickerModel(
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      isTagFilterVisible: isTagFilterVisible ?? this.isTagFilterVisible,
    );
  }
}
