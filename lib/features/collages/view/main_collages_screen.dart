import 'dart:io';

import 'package:fit_me/features/collages/view/tag_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../widgets/search_app_bar.dart';
import '../model/model.dart';
import '../effect/runtime.dart';
import '../message/message.dart';
import 'collages_grid.dart';

final searchControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class CollagesScreen extends ConsumerStatefulWidget {
  final bool selectionMode;
  final String? customTitle;
  
  const CollagesScreen({
    super.key, 
    this.selectionMode = false,
    this.customTitle,
  });

  @override
  ConsumerState<CollagesScreen> createState() => _CollagesScreenState();
}

class _CollagesScreenState extends ConsumerState<CollagesScreen> {
  late Runtime runtime;

  @override
  void initState() {
    super.initState();
    runtime = Runtime(context, ref);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      runtime.loadCollages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(collagesModelProvider);
    final controller = ref.watch(searchControllerProvider);
    final isSelectionMode = widget.selectionMode;
    
    for (var collage in model.filteredCollages) {
      precacheImage(FileImage(File(collage.imagePath)), context);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchAppBar(
        title: widget.customTitle ?? AppLocalizations.of(context).myCollages,
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
        onAdd: isSelectionMode ? null : () => runtime.dispatch(NavigateToCreateCollage()),
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

  Widget _buildBody(CollagesModel model, Runtime runtime) {
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

    if (model.filteredCollages.isEmpty) {
      return const EmptyCollagesMessage();
    }

    return CollagesGrid(
      collages: model.filteredCollages,
      onMessage: (message) => runtime.dispatch(message),
      selectionMode: widget.selectionMode,
      onCollageSelected: widget.selectionMode 
          ? (collage) => Navigator.of(context).pop(collage) 
          : null,
    );
  }
}

class EmptyCollagesMessage extends StatelessWidget {
  const EmptyCollagesMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context).emptyCollages,
        style: AppTextStyles.emptyText,
      ),
    );
  }
}
