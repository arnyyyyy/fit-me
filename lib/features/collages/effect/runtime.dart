import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../model/model.dart';
import '../message/message.dart';
import '../update/update.dart';
import '../model/saved_collage.dart';

final collagesModelProvider =
    StateProvider<CollagesModel>((ref) => const CollagesModel());

class Runtime {
  final WidgetRef ref;
  final BuildContext context;

  Runtime(this.context, this.ref);

  void dispatch(Message message) {
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

  void _handleEffect(Effect effect) {
    if (effect is NavigationEffect) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => effect.destination),
      );
    }
  }

  Future<void> loadCollages() async {
    dispatch(LoadCollages());
    try {
      final box = await Hive.openBox<SavedCollage>('collagesBox');
      final collages = box.values.toList();
      dispatch(CollagesLoaded(collages));
    } catch (e) {
      dispatch(CollagesLoadError(e.toString()));
    }
  }
  
  Future<void> loadTags() async {
    dispatch(LoadAvailableTags());
  }
}