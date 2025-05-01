import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../../features/collages/model/saved_collage.dart';
import '../../features/wardrobe/model/saved_image.dart';
import '../repositories/hive_repository.dart';

final hiveRepositoryProvider = Provider<HiveRepository>((ref) {
  return HiveRepository();
});

final imagesProvider = FutureProvider<List<SavedImage>>((ref) async {
  final repository = ref.watch(hiveRepositoryProvider);
  return repository.getAllImages();
});

final collagesProvider = FutureProvider<List<SavedCollage>>((ref) async {
  final repository = ref.watch(hiveRepositoryProvider);
  return repository.getAllCollages();
});

final tagsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(hiveRepositoryProvider);
  return repository.getAllTags();
});

final imageOperationsProvider = Provider<ImageOperations>((ref) {
  return ImageOperations(ref);
});

final collageOperationsProvider = Provider<CollageOperations>((ref) {
  return CollageOperations(ref);
});

class ImageOperations {
  final Ref _ref;

  ImageOperations(this._ref);

  Future<void> addImage(SavedImage image) async {
    final repository = _ref.read(hiveRepositoryProvider);
    await repository.addImage(image);
    _ref.invalidate(imagesProvider);
    _ref.invalidate(tagsProvider);
  }

  Future<void> deleteImage(SavedImage image) async {
    final repository = _ref.read(hiveRepositoryProvider);
    await repository.deleteImage(image);
    _ref.invalidate(imagesProvider);
    _ref.invalidate(tagsProvider);
  }
}

class CollageOperations {
  final Ref _ref;

  CollageOperations(this._ref);

  Future<void> saveCollage(
      {required String name,
      required Uint8List collageBytes,
      required List<String> tags}) async {
    if (name.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$name.png';
    final file = File(path);
    await file.writeAsBytes(collageBytes);

    final repository = _ref.read(hiveRepositoryProvider);
    await repository
        .addCollage(SavedCollage(name: name, imagePath: path, tags: tags));

    _ref.invalidate(collagesProvider);
  }

  Future<void> deleteCollage(SavedCollage collage) async {
    final repository = _ref.read(hiveRepositoryProvider);
    await repository.deleteCollage(collage);
    _ref.invalidate(collagesProvider);
  }
}
