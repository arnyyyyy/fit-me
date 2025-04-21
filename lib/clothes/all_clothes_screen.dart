import 'dart:io';

import 'package:fit_me/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/saved_image.dart';
import '../providers/hive_providers.dart';
import '../utils/app_text_styles.dart';
import 'clothes_grid.dart';
import 'custom_app_bar.dart';

class AllClothesScreen extends ConsumerStatefulWidget {
  const AllClothesScreen({super.key});

  @override
  ConsumerState<AllClothesScreen> createState() => _AllClothesScreenState();
}

class _AllClothesScreenState extends ConsumerState<AllClothesScreen> {
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
  }

  void _filterImages(String query) {
    setState(() {
      _currentQuery = query.toLowerCase();
    });
  }

  List<SavedImage> _getFilteredImages(List<SavedImage> allImages) {
    if (_currentQuery.isEmpty) {
      return allImages;
    }
    
    return allImages.where((image) {
      final nameMatches = image.name.toLowerCase().contains(_currentQuery);
      final tagMatches =
          image.tags.any((tag) => tag.toLowerCase().contains(_currentQuery));
      return nameMatches || tagMatches;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final imagesAsync = ref.watch(imagesProvider);

    return Scaffold(
      backgroundColor: AppColors.allClothesBackground,
      appBar: CustomAppBar(onSearch: _filterImages),
      body: imagesAsync.when(
        data: (allImages) {
          for (var image in allImages) {
            precacheImage(FileImage(File(image.imagePath)), context);
          }
          
          final filtered = _getFilteredImages(allImages);
          
          if (filtered.isEmpty) {
            return const EmptyClosetMessage();
          }
          
          return ClothesGrid(images: filtered);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text("smth went wrong", style: AppTextStyles.emptyText),
        ),
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
