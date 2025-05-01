import 'dart:io';
import 'package:flutter/material.dart';

import '../model/model.dart';
import '../message/message.dart';
import '../view/collage_meta_screen.dart';

abstract class CollagesEffect {}

class NavigationEffect extends CollagesEffect {
  final Widget destination;

  NavigationEffect(this.destination);
}

class SnackBarEffect extends CollagesEffect {
  final String message;

  SnackBarEffect(this.message);
}

class UpdateResult {
  final CollagesModel model;
  final Set<CollagesEffect>? effects;

  UpdateResult(this.model, [this.effects]);
}

UpdateResult update(CollagesModel model, CollagesMessage message) {
  switch (message) {
    case InitCollageScreen():
      return UpdateResult(model);

    case ImagesLoaded():
      return UpdateResult(model.copyWith(isProcessing: false));

    case ImagesLoadError(:final message):
      return UpdateResult(
        model.copyWith(isProcessing: false, error: message),
        {SnackBarEffect("Ошибка загрузки изображений: $message")},
      );

    case AddImagesToCollage(:final images):
      final updated = List<File>.from(model.images);
      for (final img in images) {
        if (!updated.contains(img)) updated.add(img);
      }
      return UpdateResult(model.copyWith(images: updated));

    case RemoveImageFromCollage(:final index):
      final updated = List<File>.from(model.images);
      if (index >= 0 && index < updated.length) {
        updated.removeAt(index);
      }
      return UpdateResult(model.copyWith(images: updated));

    case BringImageToFront(:final index):
      final updated = List<File>.from(model.images);
      if (index >= 0 && index < updated.length) {
        final image = updated.removeAt(index);
        updated.add(image);
      }
      return UpdateResult(model.copyWith(images: updated));

    case ChangeCollageBackground(:final background):
      return UpdateResult(model.copyWith(selectedBackground: background));

    case StartSavingCollage():
    case SaveCollageWithMetadata():
      return UpdateResult(model.copyWith(
        isProcessing: true,
        collageName: message is SaveCollageWithMetadata
            ? message.name
            : model.collageName,
        selectedTags: message is SaveCollageWithMetadata
            ? message.tags
            : model.selectedTags,
      ));

    case CollageImageSaved(:final collageBytes):
      return UpdateResult(
        model.copyWith(
          isProcessing: false,
          collageBytes: collageBytes,
        ),
        {NavigationEffect(CollageMetaScreen(collageBytes: collageBytes))},
      );

    case CollageImageSaveError(:final message):
    case CollageWithMetadataSaveError(:final message):
      return UpdateResult(
        model.copyWith(isProcessing: false, error: message),
        {SnackBarEffect("Ошибка сохранения коллажа: $message")},
      );

    case InitMetaScreen(:final collageBytes):
      return UpdateResult(
        model.copyWith(collageBytes: collageBytes, isTagsLoading: true),
      );

    case LoadTags():
      return UpdateResult(model.copyWith(isTagsLoading: true));

    case TagsLoaded(:final tags):
      return UpdateResult(model.copyWith(
        availableTags: tags,
        isTagsLoading: false,
      ));

    case TagsLoadError(:final message):
      return UpdateResult(
        model.copyWith(isTagsLoading: false, error: message),
        {SnackBarEffect("Ошибка загрузки тегов: $message")},
      );

    case CollageNameChanged(:final name):
      return UpdateResult(model.copyWith(collageName: name));

    case CollageTagsChanged(:final tags):
      return UpdateResult(model.copyWith(selectedTags: tags));

    case CollageWithMetadataSaved():
      return UpdateResult(
        model.copyWith(isProcessing: false),
        {
          SnackBarEffect("Коллаж успешно сохранен"),
          NavigationEffect(const PopNavigator()),
        },
      );
  }

  return UpdateResult(model);
}

class PopNavigator extends StatelessWidget {
  const PopNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
    });
    return const SizedBox.shrink();
  }
}
