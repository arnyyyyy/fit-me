import 'saved_image.dart';

class ClothesModel {
  final bool isSearching;
  final String searchQuery;
  final List<SavedImage> allImages;
  final List<SavedImage> filteredClothes;
  final bool isLoading;
  final String? errorMessage;

  const ClothesModel({
    this.isSearching = false,
    this.searchQuery = '',
    this.allImages = const [],
    this.filteredClothes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ClothesModel copyWith({
    bool? isSearching,
    String? searchQuery,
    List<SavedImage>? allImages,
    List<SavedImage>? filteredImages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ClothesModel(
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      allImages: allImages ?? this.allImages,
      filteredClothes: filteredImages ?? this.filteredClothes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
