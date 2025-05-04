import 'saved_image.dart';

class ClothesModel {
  final bool isSearching;
  final String searchQuery;
  final List<SavedImage> allImages;
  final List<SavedImage> filteredClothes;
  final bool isLoading;
  final String? errorMessage;
  final List<String> availableTags;
  final List<String> selectedTags;
  final bool isTagFilterVisible;

  const ClothesModel({
    this.isSearching = false,
    this.searchQuery = '',
    this.allImages = const [],
    this.filteredClothes = const [],
    this.isLoading = false,
    this.errorMessage,
    this.availableTags = const [],
    this.selectedTags = const [],
    this.isTagFilterVisible = false,
  });

  ClothesModel copyWith({
    bool? isSearching,
    String? searchQuery,
    List<SavedImage>? allImages,
    List<SavedImage>? filteredImages,
    bool? isLoading,
    String? errorMessage,
    List<String>? availableTags,
    List<String>? selectedTags,
    bool? isTagFilterVisible,
  }) {
    return ClothesModel(
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      allImages: allImages ?? this.allImages,
      filteredClothes: filteredImages ?? this.filteredClothes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      availableTags: availableTags ?? this.availableTags,
      selectedTags: selectedTags ?? this.selectedTags,
      isTagFilterVisible: isTagFilterVisible ?? this.isTagFilterVisible,
    );
  }
}
