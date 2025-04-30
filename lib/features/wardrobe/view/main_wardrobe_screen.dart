import 'dart:io';

import 'package:fit_me/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/app_text_styles.dart';
import '../model/model.dart';
import '../effect/runtime.dart';
import 'wardrobe_grid.dart';
import 'wardrobe_app_bar.dart';

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreen();
}

class _WardrobeScreen extends ConsumerState<WardrobeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final runtime = Runtime(context, ref);
      runtime.loadImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(modelProvider);

    for (var cloth in model.filteredClothes) {
      precacheImage(FileImage(File(cloth.imagePath)), context);
    }

    return Scaffold(
      backgroundColor: AppColors.WardrobeBackground,
      appBar: const WardrobeAppBar(),
      body: _buildBody(model),
    );
  }

  Widget _buildBody(ClothesModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null) {
      return Center(
        child: Text(
          "smth went wrong: ${model.errorMessage}",
          style: AppTextStyles.emptyText,
        ),
      );
    }

    if (model.filteredClothes.isEmpty) {
      return const EmptyWardrobeMessage();
    }

    return WardrobeGrid(images: model.filteredClothes);
  }
}

class EmptyWardrobeMessage extends StatelessWidget {
  const EmptyWardrobeMessage({super.key});

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
