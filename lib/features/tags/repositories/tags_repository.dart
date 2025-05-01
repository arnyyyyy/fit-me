import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../model/tag.dart';

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  return TagsRepositoryImpl();
});

abstract class TagsRepository {
  Future<List<String>> getAllTags();

  Future<void> saveTag(String tag);

  Future<void> removeTag(String tag);
}

class TagsRepositoryImpl implements TagsRepository {
  static const String _tagsBoxName = 'tags';

  @override
  Future<List<String>> getAllTags() async {
    try {
      final box = await Hive.openBox<Tag>(_tagsBoxName);
      return box.values.map((tag) => tag.name).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveTag(String tag) async {
    try {
      final box = await Hive.openBox<Tag>(_tagsBoxName);

      final existingTags = box.values.where((t) => t.name == tag);
      if (existingTags.isEmpty) {
        final newTag = Tag(name: tag);
        await box.add(newTag);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> removeTag(String tag) async {
    try {
      final box = await Hive.openBox<Tag>(_tagsBoxName);

      final keysToRemove = <dynamic>[];
      for (var entry in box.toMap().entries) {
        if (entry.value.name == tag) {
          keysToRemove.add(entry.key);
        }
      }

      for (var key in keysToRemove) {
        await box.delete(key);
      }
    } catch (e) {
      rethrow;
    }
  }
}
