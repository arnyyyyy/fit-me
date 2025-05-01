import 'package:flutter/material.dart';

import '../model/model.dart';
import '../message/message.dart';
import '../view/image_meta_screen.dart';
import '../view/image_editor_screen.dart';

abstract class ImageConstructorEffect {}

class NavigationEffect extends ImageConstructorEffect {
  final Widget destination;

  NavigationEffect(this.destination);
}

class SnackBarEffect extends ImageConstructorEffect {
  final String message;

  SnackBarEffect(this.message);
}

class PickImageEffect extends ImageConstructorEffect {}

class UpdateResult {
  final ImageConstructorModel model;
  final Set<ImageConstructorEffect>? effects;

  UpdateResult(this.model, [this.effects]);
}

UpdateResult update(
    ImageConstructorModel model, ImageConstructorMessage message) {
  if (message is SelectImageFromGallery) {
    return UpdateResult(
      model.copyWith(isProcessingImage: true),
      {PickImageEffect()},
    );
  } else if (message is ImageSelectedSuccess) {
    return UpdateResult(
      model.copyWith(
        processedImageBytes: message.imageBytes,
        isProcessingImage: false,
      ),
      {NavigationEffect(ImageEditorScreen(imageBytes: message.imageBytes))},
    );
  } else if (message is ImageSelectionCancelled) {
    return UpdateResult(model.copyWith(isProcessingImage: false));
  } else if (message is ImageSelectionError) {
    return UpdateResult(
      model.copyWith(
        isProcessingImage: false,
        errorMessage: message.message,
      ),
      {SnackBarEffect("Ошибка выбора изображения: ${message.message}")},
    );
  } else if (message is InitEditorWithImage) {
    return UpdateResult(model.copyWith(
      isProcessingImage: true,
      erasePoints: [],
    ));
  } else if (message is ImageLoaded) {
    return UpdateResult(model.copyWith(
      originalImage: message.image,
      originalImageBeforeRemoveBg: message.image,
      currentImage: message.image,
      isProcessingImage: false,
    ));
  } else if (message is ImageLoadError) {
    return UpdateResult(
      model.copyWith(
        isProcessingImage: false,
        errorMessage: message.message,
      ),
      {SnackBarEffect("Ошибка загрузки изображения: ${message.message}")},
    );
  } else if (message is AddErasePoint) {
    final points = List<ErasePoint>.from(model.erasePoints);
    points.add(ErasePoint(message.point, model.isErasing, model.brushRadius));

    return UpdateResult(model.copyWith(
      erasePoints: points,
    ));
  } else if (message is ChangeBrushSize) {
    return UpdateResult(model.copyWith(
      brushRadius: message.size,
    ));
  } else if (message is ToggleEraseMode) {
    return UpdateResult(model.copyWith(
      isErasing: !model.isErasing,
    ));
  } else if (message is StartRemoveBackground) {
    return UpdateResult(model.copyWith(
      isProcessingImage: true,
    ));
  } else if (message is BackgroundRemoveSuccess) {
    return UpdateResult(model.copyWith(
      originalImage: message.processedImage,
      currentImage: message.processedImage,
      erasePoints: [],
      isProcessingImage: false,
    ));
  } else if (message is BackgroundRemoveError) {
    return UpdateResult(
      model.copyWith(
        isProcessingImage: false,
        errorMessage: message.message,
      ),
      {SnackBarEffect("Ошибка удаления фона: ${message.message}")},
    );
  } else if (message is SaveEditedImage) {
    return UpdateResult(model.copyWith(
      isProcessingImage: true,
    ));
  } else if (message is ImageEditedSuccess) {
    return UpdateResult(
        model.copyWith(
          isProcessingImage: false,
          processedImageBytes: message.imageBytes,
        ),
        {NavigationEffect(ImageMetaScreen(imageBytes: message.imageBytes))});
  } else if (message is ImageEditedError) {
    return UpdateResult(
      model.copyWith(
        isProcessingImage: false,
        errorMessage: message.message,
      ),
      {SnackBarEffect("Ошибка сохранения изображения: ${message.message}")},
    );
  } else if (message is InitMetaScreen) {
    return UpdateResult(model.copyWith(
      processedImageBytes: message.imageBytes,
      isTagsLoading: true,
    ));
  } else if (message is LoadAvailableTags) {
    return UpdateResult(model.copyWith(
      isTagsLoading: true,
    ));
  } else if (message is TagsLoaded) {
    return UpdateResult(model.copyWith(
      availableTags: message.tags,
      isTagsLoading: false,
    ));
  } else if (message is TagsLoadError) {
    return UpdateResult(
      model.copyWith(
        isTagsLoading: false,
        errorMessage: message.message,
      ),
      {SnackBarEffect("Ошибка загрузки тегов: ${message.message}")},
    );
  } else if (message is ChangeImageName) {
    return UpdateResult(model.copyWith(
      imageName: message.name,
    ));
  } else if (message is ChangeSelectedTags) {
    return UpdateResult(model.copyWith(
      selectedTags: message.tags,
    ));
  } else if (message is SaveImageWithMeta) {
    return UpdateResult(model.copyWith(
      imageName: message.name,
      selectedTags: message.tags,
      isSaving: true,
    ));
  } else if (message is ImageWithMetaSaved) {
    final effects = {
      SnackBarEffect("Изображение сохранено"),
      NavigationEffect(const PopNavigator()),
    };

    return UpdateResult(
      model.copyWith(
        isSaving: false,
      ),
      effects,
    );
  } else if (message is ImageWithMetaSaveError) {
    return UpdateResult(
      model.copyWith(
        isSaving: false,
        errorMessage: message.message,
      ),
      {SnackBarEffect("Ошибка сохранения изображения: ${message.message}")},
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
