import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

abstract class ImageConstructorMessage {}

class SelectImageFromGallery extends ImageConstructorMessage {}

class ImageSelectedSuccess extends ImageConstructorMessage {
  final Uint8List imageBytes;
  ImageSelectedSuccess(this.imageBytes);
}

class ImageSelectionCancelled extends ImageConstructorMessage {}

class ImageSelectionError extends ImageConstructorMessage {
  final String message;
  ImageSelectionError(this.message);
}


class InitEditorWithImage extends ImageConstructorMessage {
  final Uint8List imageBytes;
  InitEditorWithImage(this.imageBytes);
}

class ImageLoaded extends ImageConstructorMessage {
  final ui.Image image;
  ImageLoaded(this.image);
}

class ImageLoadError extends ImageConstructorMessage {
  final String message;
  ImageLoadError(this.message);
}

class AddErasePoint extends ImageConstructorMessage {
  final Offset point;
  AddErasePoint(this.point);
}

class ChangeBrushSize extends ImageConstructorMessage {
  final double size;
  ChangeBrushSize(this.size);
}

class ToggleEraseMode extends ImageConstructorMessage {}

class StartRemoveBackground extends ImageConstructorMessage {}

class BackgroundRemoveSuccess extends ImageConstructorMessage {
  final ui.Image processedImage;
  BackgroundRemoveSuccess(this.processedImage);
}

class BackgroundRemoveError extends ImageConstructorMessage {
  final String message;
  BackgroundRemoveError(this.message);
}

class SaveEditedImage extends ImageConstructorMessage {}

class ImageEditedSuccess extends ImageConstructorMessage {
  final Uint8List imageBytes;
  ImageEditedSuccess(this.imageBytes);
}

class ImageEditedError extends ImageConstructorMessage {
  final String message;
  ImageEditedError(this.message);
}


class InitMetaScreen extends ImageConstructorMessage {
  final Uint8List imageBytes;
  InitMetaScreen(this.imageBytes);
}

class LoadAvailableTags extends ImageConstructorMessage {}

class TagsLoaded extends ImageConstructorMessage {
  final List<String> tags;
  TagsLoaded(this.tags);
}

class TagsLoadError extends ImageConstructorMessage {
  final String message;
  TagsLoadError(this.message);
}

class ChangeImageName extends ImageConstructorMessage {
  final String name;
  ChangeImageName(this.name);
}

class ChangeSelectedTags extends ImageConstructorMessage {
  final List<String> tags;
  ChangeSelectedTags(this.tags);
}

class SaveImageWithMeta extends ImageConstructorMessage {
  final String name;
  final List<String> tags;
  SaveImageWithMeta(this.name, this.tags);
}

class ImageWithMetaSaved extends ImageConstructorMessage {}

class ImageWithMetaSaveError extends ImageConstructorMessage {
  final String message;
  ImageWithMetaSaveError(this.message);
}