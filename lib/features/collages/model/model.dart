import '../model/saved_collage.dart';

class CollagesModel {
  final bool isSearching;
  final String searchQuery;
  final List<SavedCollage> allCollages;
  final List<SavedCollage> filteredCollages;
  final bool isLoading;
  final String? errorMessage;
  final List<String> availableTags;
  final List<String> selectedTags;
  final bool isTagFilterVisible;

  const CollagesModel({
    this.isSearching = false,
    this.searchQuery = '',
    this.allCollages = const [],
    this.filteredCollages = const [],
    this.isLoading = false,
    this.errorMessage,
    this.availableTags = const [],
    this.selectedTags = const [],
    this.isTagFilterVisible = false,
  });

  CollagesModel copyWith({
    bool? isSearching,
    String? searchQuery,
    List<SavedCollage>? allCollages,
    List<SavedCollage>? filteredCollages,
    bool? isLoading,
    String? errorMessage,
    List<String>? availableTags,
    List<String>? selectedTags,
    bool? isTagFilterVisible,
  }) {
    return CollagesModel(
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      allCollages: allCollages ?? this.allCollages,
      filteredCollages: filteredCollages ?? this.filteredCollages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      isTagFilterVisible: isTagFilterVisible ?? this.isTagFilterVisible,
    );
  }
}