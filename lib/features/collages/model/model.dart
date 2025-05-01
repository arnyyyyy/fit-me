import '../model/saved_collage.dart';

class CollagesModel {
  final bool isSearching;
  final String searchQuery;
  final List<SavedCollage> allCollages;
  final List<SavedCollage> filteredCollages;
  final bool isLoading;
  final String? errorMessage;

  const CollagesModel({
    this.isSearching = false,
    this.searchQuery = '',
    this.allCollages = const [],
    this.filteredCollages = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  CollagesModel copyWith({
    bool? isSearching,
    String? searchQuery,
    List<SavedCollage>? allCollages,
    List<SavedCollage>? filteredCollages,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CollagesModel(
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      allCollages: allCollages ?? this.allCollages,
      filteredCollages: filteredCollages ?? this.filteredCollages,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}