import 'dart:io';
import 'dart:ui' as ui;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/services/image_service.dart';
import '../../wardrobe/model/saved_image.dart';
import '../../main/main_screen.dart';
import '../model/model.dart';
import '../message/message.dart';
import '../update/update.dart';

final imageConstructorModelProvider = StateProvider<ImageConstructorModel>(
  (ref) => const ImageConstructorModel(),
);

class ImageConstructorRuntime {
  final WidgetRef ref;
  final BuildContext context;

  ImageConstructorRuntime(this.context, this.ref);

  void dispatch(ImageConstructorMessage message) {
    final currentModel = ref.read(imageConstructorModelProvider);
    final result = update(currentModel, message);

    if (result.model != currentModel) {
      ref.read(imageConstructorModelProvider.notifier).state = result.model;
    }

    if (result.effects != null) {
      for (final effect in result.effects!) {
        _handleEffect(effect);
      }
    }
  }

  void _handleEffect(ImageConstructorEffect effect) {
    if (effect is NavigationEffect) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => effect.destination),
      );
    } else if (effect is NavigateToMainScreenEffect) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainScreen(initialTabIndex: effect.tabIndex),
        ),
        (route) => false,
      );
    } else if (effect is SnackBarEffect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(effect.message)),
      );
    } else if (effect is PickImageEffect) {
      _pickImageFromGallery();
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        dispatch(ImageSelectionCancelled());
        return;
      }

      if (context.mounted) {
        final bytes = await pickedFile.readAsBytes();
        dispatch(ImageSelectedSuccess(bytes));
      }
    } catch (e) {
      dispatch(ImageSelectionError(e.toString()));
    }
  }

  Future<void> loadImage(Uint8List imageBytes) async {
    dispatch(InitEditorWithImage(imageBytes));

    try {
      final image = await _decodeImageFromBytes(imageBytes);

      if (context.mounted) {
        dispatch(ImageLoaded(image));
      }
    } catch (e) {
      if (context.mounted) {
        dispatch(ImageLoadError(e.toString()));
      }
    }
  }

  Future<ui.Image> _decodeImageFromBytes(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 1024,
    );
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> removeBackground() async {
    final model = ref.read(imageConstructorModelProvider);
    if (model.currentImage == null) return;

    dispatch(StartRemoveBackground());

    try {
      final editedBytes = await generateEditedImageBytes();

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_image.png');
      await tempFile.writeAsBytes(editedBytes);

      final service = ImageService();
      final noBgPath = await service.removeBackground(tempFile);
      final noBgBytes = await File(noBgPath).readAsBytes();

      final codec = await ui.instantiateImageCodec(noBgBytes);
      final frame = await codec.getNextFrame();

      dispatch(BackgroundRemoveSuccess(frame.image));
    } catch (e) {
      dispatch(BackgroundRemoveError(e.toString()));
    }
  }

  Future<Uint8List> generateEditedImageBytes() async {
    final model = ref.read(imageConstructorModelProvider);
    if (model.originalImage == null) {
      throw Exception("Image is not loaded");
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(model.originalImage!, Offset.zero, Paint());

    for (final p in model.erasePoints) {
      if (p.isErase) {
        final paint = Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p.point, p.radius, paint);
      } else {
        if (model.originalImageBeforeRemoveBg != null) {
          final srcRect = Rect.fromCenter(
            center: p.point,
            width: p.radius * 2,
            height: p.radius * 2,
          );
          canvas.drawImageRect(
            model.originalImageBeforeRemoveBg!,
            srcRect,
            srcRect,
            Paint(),
          );
        }
      }
    }

    final image = model.originalImage!;
    final renderedImage = await recorder.endRecording().toImage(
          image.width,
          image.height,
        );
    final byteData =
        await renderedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> saveEditedImage() async {
    dispatch(SaveEditedImage());

    try {
      final editedBytes = await generateEditedImageBytes();
      dispatch(ImageEditedSuccess(editedBytes));
    } catch (e) {
      dispatch(ImageEditedError(e.toString()));
    }
  }

  Future<void> loadTags() async {
    dispatch(LoadAvailableTags());

    try {
      final imagesBox = await Hive.openBox<SavedImage>('imagesBox');

      final Set<String> tagsSet = {};
      for (var img in imagesBox.values) {
        tagsSet.addAll(img.tags);
      }

      final tags = tagsSet.toList()..sort();
      dispatch(TagsLoaded(tags));
    } catch (e) {
      dispatch(TagsLoadError(e.toString()));
    }
  }

  Future<void> saveImageWithMeta(
      String name, List<String> tags, Uint8List imageBytes) async {
    if (name.trim().isEmpty) {
      dispatch(ImageWithMetaSaveError("Name cannot be empty"));
      return;
    }

    dispatch(SaveImageWithMeta(name, tags));

    try {
      final dir = await getApplicationDocumentsDirectory();
      final imagePath = '${dir.path}/$name.png';

      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      final savedImage =
          SavedImage(name: name, imagePath: imagePath, tags: tags);

      final box = await Hive.openBox<SavedImage>('imagesBox');
      await box.add(savedImage);

      dispatch(ImageWithMetaSaved());
    } catch (e) {
      dispatch(ImageWithMetaSaveError(e.toString()));
    }
  }
}
