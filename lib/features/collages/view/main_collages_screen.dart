import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../model/model.dart';
import '../effect/runtime.dart';
import 'collages_grid.dart';
import 'collages_app_bar.dart';

class CollagesScreen extends ConsumerStatefulWidget {
  const CollagesScreen({super.key});

  @override
  ConsumerState<CollagesScreen> createState() => _CollagesScreenState();
}

class _CollagesScreenState extends ConsumerState<CollagesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final runtime = Runtime(context, ref);
      runtime.loadCollages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(collagesModelProvider);

    for (var collage in model.filteredCollages) {
      precacheImage(FileImage(File(collage.imagePath)), context);
    }

    return Scaffold(
      backgroundColor: AppColors.WardrobeBackground,
      appBar: const CollagesAppBar(),
      body: _buildBody(model),
    );
  }

  Widget _buildBody(CollagesModel model) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null) {
      return Center(
        child: Text(
          "Что-то пошло не так: ${model.errorMessage}",
          style: AppTextStyles.emptyText,
        ),
      );
    }

    if (model.filteredCollages.isEmpty) {
      return const EmptyCollagesMessage();
    }

    return CollagesGrid(collages: model.filteredCollages);
  }
}

class EmptyCollagesMessage extends StatelessWidget {
  const EmptyCollagesMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "У вас пока нет коллажей...",
        style: AppTextStyles.emptyText,
      ),
    );
  }
}
