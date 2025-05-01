import 'package:flutter/material.dart';

import '../model/model.dart';
import '../message/message.dart';
import '../view/image_meta_screen.dart';
import '../view/image_editor_screen.dart';
import '../../main/main_screen.dart';

abstract class ImageConstructorEffect {}

class NavigationEffect extends ImageConstructorEffect {
  final Widget destination;

  NavigationEffect(this.destination);
}

class NavigateToMainScreenEffect extends ImageConstructorEffect {
  final int tabIndex;

  NavigateToMainScreenEffect(this.tabIndex);
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
  switch (message) {
    case SelectImageFromGallery():
      return UpdateResult(
        model.copyWith(isProcessingImage: true),
        {PickImageEffect()},
      );

    case ImageSelectedSuccess(:final imageBytes):
      return UpdateResult(
        model.copyWith(
          processedImageBytes: imageBytes,
          isProcessingImage: false,
        ),
        {NavigationEffect(ImageEditorScreen(imageBytes: imageBytes))},
      );

    case ImageSelectionCancelled():
      return UpdateResult(model.copyWith(isProcessingImage: false));

    case ImageSelectionError(:final message):
      return UpdateResult(
        model.copyWith(
          isProcessingImage: false,
          errorMessage: message,
        ),
        {SnackBarEffect("Ошибка выбора изображения: $message")},
      );

    case InitEditorWithImage():
      return UpdateResult(model.copyWith(
        isProcessingImage: true,
        erasePoints: [],
      ));

    case ImageLoaded(:final image):
      return UpdateResult(model.copyWith(
        originalImage: image,
        originalImageBeforeRemoveBg: image,
        currentImage: image,
        isProcessingImage: false,
      ));

    case ImageLoadError(:final message):
      return UpdateResult(
        model.copyWith(
          isProcessingImage: false,
          errorMessage: message,
        ),
        {SnackBarEffect("Ошибка загрузки изображения: $message")},
      );

    case AddErasePoint(:final point):
      final updated = List<ErasePoint>.from(model.erasePoints)
        ..add(ErasePoint(point, model.isErasing, model.brushRadius));
      return UpdateResult(model.copyWith(erasePoints: updated));

    case ChangeBrushSize(:final size):
      return UpdateResult(model.copyWith(brushRadius: size));

    case ToggleEraseMode():
      return UpdateResult(model.copyWith(isErasing: !model.isErasing));

    case StartRemoveBackground():
      return UpdateResult(model.copyWith(isProcessingImage: true));

    case BackgroundRemoveSuccess(:final processedImage):
      return UpdateResult(model.copyWith(
        originalImage: processedImage,
        currentImage: processedImage,
        erasePoints: [],
        isProcessingImage: false,
      ));

    case BackgroundRemoveError(:final message):
      return UpdateResult(
        model.copyWith(
          isProcessingImage: false,
          errorMessage: message,
        ),
        {SnackBarEffect("Ошибка удаления фона: $message")},
      );

    case SaveEditedImage():
      return UpdateResult(model.copyWith(isProcessingImage: true));

    case ImageEditedSuccess(:final imageBytes):
      return UpdateResult(
        model.copyWith(
          isProcessingImage: false,
          processedImageBytes: imageBytes,
        ),
        {NavigationEffect(ImageMetaScreen(imageBytes: imageBytes))},
      );

    case ImageEditedError(:final message):
      return UpdateResult(
        model.copyWith(
          isProcessingImage: false,
          errorMessage: message,
        ),
        {SnackBarEffect("Ошибка сохранения изображения: $message")},
      );

    case InitMetaScreen(:final imageBytes):
      return UpdateResult(model.copyWith(
        processedImageBytes: imageBytes,
        isTagsLoading: true,
      ));

    case LoadAvailableTags():
      return UpdateResult(model.copyWith(isTagsLoading: true));

    case TagsLoaded(:final tags):
      return UpdateResult(model.copyWith(
        availableTags: tags,
        isTagsLoading: false,
      ));

    case TagsLoadError(:final message):
      return UpdateResult(
        model.copyWith(
          isTagsLoading: false,
          errorMessage: message,
        ),
        {SnackBarEffect("Ошибка загрузки тегов: $message")},
      );

    case ChangeImageName(:final name):
      return UpdateResult(model.copyWith(imageName: name));

    case ChangeSelectedTags(:final tags):
      return UpdateResult(model.copyWith(selectedTags: tags));

    case SaveImageWithMeta(:final name, :final tags):
      return UpdateResult(model.copyWith(
        imageName: name,
        selectedTags: tags,
        isSaving: true,
      ));

    case ImageWithMetaSaved():
      return UpdateResult(
        model.copyWith(isSaving: false),
        {
          SnackBarEffect("Изображение сохранено"),
          NavigateToMainScreenEffect(2),
        },
      );

    case ImageWithMetaSaveError(:final message):
      return UpdateResult(
        model.copyWith(
          isSaving: false,
          errorMessage: message,
        ),
        {SnackBarEffect("Ошибка сохранения изображения: $message")},
      );
  }

  return UpdateResult(model);
}

class NavigateToMainScreen extends StatelessWidget {
  final int tabIndex;

  const NavigateToMainScreen({super.key, this.tabIndex = 2});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainScreen(initialTabIndex: tabIndex),
        ),
        (route) => false,
      );
    });
    return const SizedBox.shrink();
  }
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
