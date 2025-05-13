import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../model/model.dart';
import '../message/message.dart';
import '../view/collage_saving_screen.dart';

abstract class CollagesEffect {}

class NavigationEffect extends CollagesEffect {
  final Widget destination;

  NavigationEffect(this.destination);
}

class NavigateToMainScreenEffect extends CollagesEffect {
  final int tabIndex;

  NavigateToMainScreenEffect(this.tabIndex);
}

class SnackBarEffect extends CollagesEffect {
  final String message;

  SnackBarEffect(this.message);
}

class LocalizableSnackBarEffect extends CollagesEffect {
  final String messageKey;
  final Map<String, String>? args;

  LocalizableSnackBarEffect(this.messageKey, [this.args]);

  String getLocalizedMessage(BuildContext context) {
    final loc = AppLocalizations.of(context);

    switch (messageKey) {
      case 'imagesLoadError':
        return loc.imagesLoadError(args?['message'] ?? '');
      case 'saveError':
        return loc.saveError(args?['message'] ?? '');
      case 'tagsLoadError':
        return loc.tagsLoadError(args?['message'] ?? '');
      case 'imageSaved':
        return loc.imageSaved;
      default:
        return messageKey;
    }
  }
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
        {
          LocalizableSnackBarEffect('imagesLoadError', {'message': message})
        },
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
      
    case ChangeCustomBackgroundColor(:final color):
      return UpdateResult(model.copyWith(
        customBackgroundColor: color,
        selectedBackground: CollageBackground.custom,
      ));

    case StartSavingCollage():
    case SaveCollageWithMetadata():
      return UpdateResult(
        model.copyWith(
          isProcessing: true,
          collageName: message is SaveCollageWithMetadata
              ? message.name
              : model.collageName,
          selectedTags: message is SaveCollageWithMetadata
              ? message.tags
              : model.selectedTags,
        ),
      );

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
        {
          LocalizableSnackBarEffect('saveError', {'message': message})
        },
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
        {
          LocalizableSnackBarEffect('tagsLoadError', {'message': message})
        },
      );

    case CollageNameChanged(:final name):
      return UpdateResult(model.copyWith(collageName: name));

    case CollageTagsChanged(:final tags):
      return UpdateResult(model.copyWith(selectedTags: tags));

    case CollageWithMetadataSaved():
      return UpdateResult(
        model.copyWith(isProcessing: false),
        {
          LocalizableSnackBarEffect('imageSaved'),
          NavigateToMainScreenEffect(0),
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
