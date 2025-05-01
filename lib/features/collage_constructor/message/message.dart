import 'dart:io';
import 'dart:typed_data';

import '../../collages/model/saved_collage.dart';
import '../model/model.dart';

abstract class CollagesMessage {}

class InitCollageScreen extends CollagesMessage {}

class ImagesLoaded extends CollagesMessage {
  final List<File> images;

  ImagesLoaded(this.images);
}

class ImagesLoadError extends CollagesMessage {
  final String message;

  ImagesLoadError(this.message);
}

class AddImagesToCollage extends CollagesMessage {
  final List<File> images;

  AddImagesToCollage(this.images);
}

class RemoveImageFromCollage extends CollagesMessage {
  final int index;

  RemoveImageFromCollage(this.index);
}

class BringImageToFront extends CollagesMessage {
  final int index;

  BringImageToFront(this.index);
}

class ChangeCollageBackground extends CollagesMessage {
  final CollageBackground background;

  ChangeCollageBackground(this.background);
}

class StartSavingCollage extends CollagesMessage {}

class CollageImageSaved extends CollagesMessage {
  final Uint8List collageBytes;

  CollageImageSaved(this.collageBytes);
}

class CollageImageSaveError extends CollagesMessage {
  final String message;

  CollageImageSaveError(this.message);
}

class InitMetaScreen extends CollagesMessage {
  final Uint8List collageBytes;

  InitMetaScreen(this.collageBytes);
}

class LoadTags extends CollagesMessage {}

class TagsLoaded extends CollagesMessage {
  final List<String> tags;

  TagsLoaded(this.tags);
}

class TagsLoadError extends CollagesMessage {
  final String message;

  TagsLoadError(this.message);
}

class CollageNameChanged extends CollagesMessage {
  final String name;

  CollageNameChanged(this.name);
}

class CollageTagsChanged extends CollagesMessage {
  final List<String> tags;

  CollageTagsChanged(this.tags);
}

class SaveCollageWithMetadata extends CollagesMessage {
  final String name;
  final List<String> tags;

  SaveCollageWithMetadata(this.name, this.tags);
}

class CollageWithMetadataSaved extends CollagesMessage {
  final SavedCollage collage;

  CollageWithMetadataSaved(this.collage);
}

class CollageWithMetadataSaveError extends CollagesMessage {
  final String message;

  CollageWithMetadataSaveError(this.message);
}
