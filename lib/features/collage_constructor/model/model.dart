import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../widgets/erasable_image.dart';

class CollagesModel {
  final bool isProcessing;
  final List<File> images;
  final CollageBackground selectedBackground;
  final Color customBackgroundColor;

  final String collageName;
  final List<String> selectedTags;
  final Uint8List? collageBytes;
  final List<String> availableTags;
  final bool isTagsLoading;
  final String? error;
  
  final bool isEraserMode;
  final double eraserSize;
  final Map<String, ErasableMask> eraseMasks;

  const CollagesModel({
    this.isProcessing = false,
    this.images = const [],
    this.selectedBackground = CollageBackground.transparent,
    this.customBackgroundColor = const Color(0xFF613E3E),
    this.collageName = '',
    this.selectedTags = const [],
    this.collageBytes,
    this.availableTags = const [],
    this.isTagsLoading = false,
    this.error,
    this.isEraserMode = false,
    this.eraserSize = 20.0,
    this.eraseMasks = const {},
  });

  CollagesModel copyWith({
    bool? isProcessing,
    List<File>? images,
    CollageBackground? selectedBackground,
    Color? customBackgroundColor,
    String? collageName,
    List<String>? selectedTags,
    Uint8List? collageBytes,
    List<String>? availableTags,
    bool? isTagsLoading,
    String? error,
    bool? isEraserMode,
    double? eraserSize,
    Map<String, ErasableMask>? eraseMasks,
  }) {
    return CollagesModel(
      isProcessing: isProcessing ?? this.isProcessing,
      images: images ?? this.images,
      selectedBackground: selectedBackground ?? this.selectedBackground,
      customBackgroundColor: customBackgroundColor ?? this.customBackgroundColor,
      collageName: collageName ?? this.collageName,
      selectedTags: selectedTags ?? this.selectedTags,
      collageBytes: collageBytes ?? this.collageBytes,
      availableTags: availableTags ?? this.availableTags,
      isTagsLoading: isTagsLoading ?? this.isTagsLoading,
      error: error ?? this.error,
      isEraserMode: isEraserMode ?? this.isEraserMode,
      eraserSize: eraserSize ?? this.eraserSize,
      eraseMasks: eraseMasks ?? this.eraseMasks,
    );
  }
  
  CollagesModel updateImageMask(String imagePath, ErasableMask mask) {
    final newMasks = Map<String, ErasableMask>.from(eraseMasks);
    newMasks[imagePath] = mask;
    return copyWith(eraseMasks: newMasks);
  }
}

enum CollageBackground {
  transparent,
  white,
  black,
  custom,
}
