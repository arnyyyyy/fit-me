import 'dart:io';

import 'package:fit_me/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/filter_providers.dart';
import '../../utils/app_text_styles.dart';
import 'clothes_grid.dart';
import 'custom_app_bar.dart';

class AllClothesScreen extends ConsumerWidget {
  const AllClothesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredImagesAsync = ref.watch(filteredImagesProvider);

    return Scaffold(
      backgroundColor: AppColors.allClothesBackground,
      appBar: const CustomAppBar(),
      body: filteredImagesAsync.when(
        data: (images) {
          for (var image in images) {
            precacheImage(FileImage(File(image.imagePath)), context);
          }
          
          if (images.isEmpty) {
            return const EmptyClosetMessage();
          }
          
          return ClothesGrid(images: images);
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
