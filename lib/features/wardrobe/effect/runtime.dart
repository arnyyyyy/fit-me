import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../model/model.dart';
import '../message/message.dart';
import '../update/update.dart';
import '../model/saved_image.dart';

final modelProvider =
    StateProvider<ClothesModel>((ref) => const ClothesModel());

class Runtime {
  final WidgetRef ref;
  final BuildContext context;

  Runtime(this.context, this.ref);

  void dispatch(Message message) {
    final currentModel = ref.read(modelProvider);
    final result = update(currentModel, message);

    if (result.model != currentModel) {
      ref.read(modelProvider.notifier).state = result.model;
    }

    if (result.effects != null) {
      for (final effect in result.effects!) {
        _handleEffect(effect);
      }
    }
  }

  void _handleEffect(Effect effect) {
    if (effect is NavigationEffect) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => effect.destination),
      );
    }
  }

  Future<void> loadImages() async {
    dispatch(LoadImages());
    try {
      final box = await Hive.openBox<SavedImage>('imagesBox');
      final images = box.values.toList();
      dispatch(ImagesLoaded(images));
    } catch (e) {
      dispatch(ImagesLoadError(e.toString()));
    }
  }
  
  Future<void> loadTags() async {
    dispatch(LoadAvailableTags());
  }
}
