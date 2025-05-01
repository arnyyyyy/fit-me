import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/model.dart';
import '../message/message.dart';
import '../effect/effect.dart';
import '../update/update.dart';
import '../repositories/tags_repository.dart';

final tagsModelProvider = StateProvider<TagsModel>(
  (ref) => const TagsModel(),
);

class TagsRuntime {
  final BuildContext context;
  final WidgetRef ref;
  final ValueChanged<List<String>>? onTagsChanged;
  bool _isDisposed = false;

  TagsRuntime(this.context, this.ref, {this.onTagsChanged});

  void dispatch(TagsMessage message) {
    if (_isDisposed) return;

    final currentModel = ref.read(tagsModelProvider);
    final result = update(currentModel, message);

    if (result.model != currentModel) {
      Future.microtask(() {
        if (!_isDisposed) {
          ref.read(tagsModelProvider.notifier).state = result.model;
        }
      });
    }

    if (result.effects != null) {
      for (final effect in result.effects!) {
        _handleEffect(effect);
      }
    }
  }

  void dispose() {
    _isDisposed = true;
  }

  void _handleEffect(TagsEffect effect) {
    if (effect is LoadTagsEffect) {
      _loadAvailableTags();
    } else if (effect is TagsUpdatedCallbackEffect) {
      if (onTagsChanged != null) {
        onTagsChanged!(effect.tags);
      }
      _saveTagsToRepository(effect.tags);
    } else if (effect is ShowErrorMessageEffect) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(effect.message)),
      );
    }
  }

  Future<void> _loadAvailableTags() async {
    try {
      final repository = ref.read(tagsRepositoryProvider);
      final allTags = await repository.getAllTags();
      dispatch(TagsLoaded(allTags));
    } catch (e) {
      dispatch(TagsLoadError(e.toString()));
    }
  }

  Future<void> _saveTagsToRepository(List<String> tags) async {
    try {
      final repository = ref.read(tagsRepositoryProvider);
      for (final tag in tags) {
        await repository.saveTag(tag);
      }
    } catch (e) {
      dispatch(TagsLoadError("Ошибка при сохранении тегов: ${e.toString()}"));
    }
  }

  void initWithTags(List<String> initialTags, List<String> availableTags) {
    dispatch(TagsLoaded(availableTags));
    dispatch(SetInitialTags(initialTags));
    dispatch(LoadTags());
  }
}
