import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/common/base_runtime.dart';
import '../../main/main_screen.dart';
import '../../wardrobe/model/saved_image.dart';
import '../model/model.dart';
import '../message/message.dart';
import '../update/update.dart';
import '../../collages/model/saved_collage.dart';

final collagesModelProvider =
    StateProvider<CollagesModel>((ref) => const CollagesModel());

class CollagesRuntime extends BaseRuntime<CollagesMessage> {
  final WidgetRef ref;
  final BuildContext context;

  CollagesRuntime(this.context, this.ref);

  @override
  void dispatch(CollagesMessage message) {
    final currentModel = ref.read(collagesModelProvider);
    final result = update(currentModel, message);

    if (result.model != currentModel) {
      ref.read(collagesModelProvider.notifier).state = result.model;
    }

    if (result.effects != null) {
      for (final effect in result.effects!) {
        _handleEffect(effect);
      }
    }
  }

  void _handleEffect(CollagesEffect effect) {
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
    } else if (effect is LocalizableSnackBarEffect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(effect.getLocalizedMessage(context))),
      );
    }
  }

  Future<List<File>> loadSavedImages() async {
    try {
      final box = await Hive.openBox<SavedImage>('imagesBox');
      final images = box.values.toList();
      return images.map((img) => File(img.imagePath)).toList();
    } catch (e) {
      dispatch(ImagesLoadError(e.toString()));
      return [];
    }
  }

  Future<void> loadTags() async {
    dispatch(LoadTags());
    try {
      final imagesBox = await Hive.openBox<SavedImage>('imagesBox');
      final collagesBox = await Hive.openBox<SavedCollage>('collagesBox');

      final Set<String> tagsSet = {};
      for (var img in imagesBox.values) {
        tagsSet.addAll(img.tags);
      }
      for (var collage in collagesBox.values) {
        tagsSet.addAll(collage.tags);
      }

      final tags = tagsSet.toList()..sort();
      dispatch(TagsLoaded(tags));
    } catch (e) {
      dispatch(TagsLoadError(e.toString()));
    }
  }

  Future<void> captureCollageImage(GlobalKey stackKey) async {
    dispatch(StartSavingCollage());

    try {
      RenderRepaintBoundary boundary =
          stackKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      dispatch(CollageImageSaved(pngBytes));
    } catch (e) {
      dispatch(CollageImageSaveError(e.toString()));
    }
  }

  Future<void> saveCollageWithMetadata(
      String name, List<String> tags, Uint8List collageBytes) async {
    if (name.trim().isEmpty) {
      dispatch(
          CollageWithMetadataSaveError("Имя коллажа не может быть пустым"));
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/collage_$timestamp.png';

      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(collageBytes);

      final savedCollage = SavedCollage(
        name: name,
        imagePath: imagePath,
        tags: tags,
      );

      final box = await Hive.openBox<SavedCollage>('collagesBox');
      await box.add(savedCollage);

      dispatch(CollageWithMetadataSaved(savedCollage));
    } catch (e) {
      dispatch(CollageWithMetadataSaveError(e.toString()));
    }
  }
}
