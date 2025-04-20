import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/saved_image.dart';
import '../utils/app_text_styles.dart';
import 'clothes_grid.dart';
import 'custom_app_bar.dart';

class AllClothesScreen extends StatefulWidget {
  const AllClothesScreen({super.key});

  @override
  State<AllClothesScreen> createState() => _AllClothesScreenState();
}

class _AllClothesScreenState extends State<AllClothesScreen> {
  late Future<Box<SavedImage>> _imageBoxFuture;
  List<SavedImage> _allImages = [];
  List<SavedImage> _filteredImages = [];

  @override
  void initState() {
    super.initState();
    _imageBoxFuture = Hive.openBox<SavedImage>('imagesBox');
    _imageBoxFuture.then((box) {
      final images = box.values.toList();
      setState(() {
        _allImages = images;
        _filteredImages = images;
      });

      for (var image in images) {
        precacheImage(FileImage(File(image.imagePath)), context);
      }
    });
  }

  void _filterImages(String query) {
    final lowerQuery = query.toLowerCase();
    final filtered = _allImages.where((image) {
      final nameMatches = image.name.toLowerCase().contains(lowerQuery);
      final tagMatches =
          image.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      return nameMatches || tagMatches;
    }).toList();

    setState(() {
      _filteredImages = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: CustomAppBar(onSearch: _filterImages),
      body: FutureBuilder<Box<SavedImage>>(
        future: _imageBoxFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_filteredImages.isEmpty) {
            return const EmptyClosetMessage();
          }

          return ClothesGrid(images: _filteredImages);
        },
      ),
    );
  }
}

class EmptyClosetMessage extends StatelessWidget {
  const EmptyClosetMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "the closet is still empty...",
        style: AppTextStyles.emptyText,
      ),
    );
  }
}
