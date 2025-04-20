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

  @override
  void initState() {
    super.initState();
    _imageBoxFuture = Hive.openBox<SavedImage>('imagesBox');
    _imageBoxFuture.then((box) {
      for (var image in box.values) {
        precacheImage(FileImage(File(image.imagePath)), context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: const CustomAppBar(),
      body: FutureBuilder<Box<SavedImage>>(
        future: _imageBoxFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final images = snapshot.data!.values.toList();

          if (images.isEmpty) {
            return const EmptyClosetMessage();
          }

          return ClothesGrid(images: images);
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
