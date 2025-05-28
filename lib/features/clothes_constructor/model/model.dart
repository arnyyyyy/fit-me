import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

class ImageConstructorModel {
  final ui.Image? originalImage;
  final ui.Image? originalImageBeforeRemoveBg;
  final ui.Image? currentImage;
  final List<ErasePoint> erasePoints;
  final double brushRadius;
  final bool isErasing;
  final bool isProcessingImage;
  final String? errorMessage;
  final double userScale;
  final Offset userOffset;
  
  final String imageName;
  final String imageDescription;
  final List<String> selectedTags;
  final List<String> availableTags;
  final bool isTagsLoading;
  final bool isSaving;
  final Uint8List? processedImageBytes;

  const ImageConstructorModel({
    this.originalImage,
    this.originalImageBeforeRemoveBg,
    this.currentImage,
    this.erasePoints = const [],
    this.brushRadius = 25.0,
    this.isErasing = true,
    this.isProcessingImage = false,
    this.errorMessage,
    this.userScale = 1.0,
    this.userOffset = const Offset(0, 0),
    this.imageName = '',
    this.imageDescription = '',
    this.selectedTags = const [],
    this.availableTags = const [],
    this.isTagsLoading = false,
    this.isSaving = false,
    this.processedImageBytes,
  });

  ImageConstructorModel copyWith({
    ui.Image? originalImage,
    ui.Image? originalImageBeforeRemoveBg,
    ui.Image? currentImage,
    List<ErasePoint>? erasePoints,
    double? brushRadius,
    bool? isErasing,
    bool? isProcessingImage,
    String? errorMessage,
    double? userScale,
    Offset? userOffset,
    String? imageName,
    String? imageDescription,
    List<String>? selectedTags,
    List<String>? availableTags,
    bool? isTagsLoading,
    bool? isSaving,
    Uint8List? processedImageBytes,
  }) {
    return ImageConstructorModel(
      originalImage: originalImage ?? this.originalImage,
      originalImageBeforeRemoveBg: originalImageBeforeRemoveBg ?? this.originalImageBeforeRemoveBg,
      currentImage: currentImage ?? this.currentImage,
      erasePoints: erasePoints ?? this.erasePoints,
      brushRadius: brushRadius ?? this.brushRadius,
      isErasing: isErasing ?? this.isErasing,
      isProcessingImage: isProcessingImage ?? this.isProcessingImage,
      errorMessage: errorMessage ?? this.errorMessage,
      userScale: userScale ?? this.userScale,
      userOffset: userOffset ?? this.userOffset,
      imageName: imageName ?? this.imageName,
      imageDescription: imageDescription ?? this.imageDescription,
      selectedTags: selectedTags ?? this.selectedTags,
      availableTags: availableTags ?? this.availableTags,
      isTagsLoading: isTagsLoading ?? this.isTagsLoading,
      isSaving: isSaving ?? this.isSaving,
      processedImageBytes: processedImageBytes ?? this.processedImageBytes,
    );
  }
}

class ErasePoint {
  final Offset point;
  final bool isErase;
  final double radius;

  ErasePoint(this.point, this.isErase, this.radius);
}