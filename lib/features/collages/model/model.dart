import 'dart:io';
import 'dart:typed_data';

class CollagesModel {
  final bool isProcessing;
  final List<File> images;
  final CollageBackground selectedBackground;

  final String collageName;
  final List<String> selectedTags;
  final Uint8List? collageBytes;
  final List<String> availableTags;
  final bool isTagsLoading;
  final String? error;

  const CollagesModel({
    this.isProcessing = false,
    this.images = const [],
    this.selectedBackground = CollageBackground.transparent,
    this.collageName = '',
    this.selectedTags = const [],
    this.collageBytes,
    this.availableTags = const [],
    this.isTagsLoading = false,
    this.error,
  });

  CollagesModel copyWith({
    bool? isProcessing,
    List<File>? images,
    CollageBackground? selectedBackground,
    String? collageName,
    List<String>? selectedTags,
    Uint8List? collageBytes,
    List<String>? availableTags,
    bool? isTagsLoading,
    String? error,
  }) {
    return CollagesModel(
      isProcessing: isProcessing ?? this.isProcessing,
      images: images ?? this.images,
      selectedBackground: selectedBackground ?? this.selectedBackground,
      collageName: collageName ?? this.collageName,
      selectedTags: selectedTags ?? this.selectedTags,
      collageBytes: collageBytes ?? this.collageBytes,
      availableTags: availableTags ?? this.availableTags,
      isTagsLoading: isTagsLoading ?? this.isTagsLoading,
      error: error ?? this.error,
    );
  }
}

enum CollageBackground {
  transparent,
  white,
  black,
}
