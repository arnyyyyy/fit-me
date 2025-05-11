import 'dart:io';

import 'package:fit_me/features/wardrobe/view/tag_filter_bar.dart';
import 'package:fit_me/features/wardrobe/message/message.dart';
import 'package:fit_me/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_text_styles.dart';
import '../../../widgets/search_app_bar.dart';
import '../model/model.dart';
import '../effect/runtime.dart';
import 'wardrobe_grid.dart';

final searchControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class WardrobeScreen extends ConsumerStatefulWidget {
  const WardrobeScreen({super.key});

  @override
  ConsumerState<WardrobeScreen> createState() => _WardrobeScreen();
}

class _WardrobeScreen extends ConsumerState<WardrobeScreen> {
  late Runtime runtime;

  @override
  void initState() {
    super.initState();
    runtime = Runtime(context, ref);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      runtime.loadImages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(modelProvider);
    final controller = ref.watch(searchControllerProvider);

    for (var cloth in model.filteredClothes) {
      precacheImage(FileImage(File(cloth.imagePath)), context);
    }

    return Scaffold(
      backgroundColor: AppColors.wardrobeBackground,
      appBar: SearchAppBar(
        title: AppLocalizations.of(context).myClothes,
        hintText: AppLocalizations.of(context).searchNameOrTags,
        model: model,
        controller: controller,
        onSearchChanged: (query) => runtime.dispatch(SearchQueryChanged(query)),
        onToggleSearch: () =>
            runtime.dispatch(ToggleSearch(!model.isSearching)),
        onToggleFilter: () {
          runtime.dispatch(ToggleTagFilter(!model.isTagFilterVisible));
          if (!model.isTagFilterVisible) {
            runtime.dispatch(LoadAvailableTags());
          }
        },
        onLoadTags: () => runtime.dispatch(LoadAvailableTags()),
        onAdd: () => runtime.dispatch(NavigateToAddImage()),
      ),
      body: Column(
        children: [
          if (model.isTagFilterVisible && model.availableTags.isNotEmpty)
            const TgFilterBar(),
          Expanded(
            child: _buildBody(model, runtime),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ClothesModel model, Runtime runtime) {
    if (model.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (model.errorMessage != null) {
      return Center(
        child: Text(
          AppLocalizations.of(context).error(model.errorMessage!),
          style: AppTextStyles.emptyText,
        ),
      );
    }

    if (model.filteredClothes.isEmpty) {
      return const EmptyWardrobeMessage();
    }

    return WardrobeGrid(
      images: model.filteredClothes,
      onMessage: (message) => runtime.dispatch(message),
    );
  }
}

class EmptyWardrobeMessage extends StatelessWidget {
  const EmptyWardrobeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context).emptyWardrobe,
        style: AppTextStyles.emptyText,
      ),
    );
  }
}
