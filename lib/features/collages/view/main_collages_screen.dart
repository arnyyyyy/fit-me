import 'dart:io';

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
    final runtime = Runtime(context, ref);
    final controller = ref.watch(searchControllerProvider);

    for (var collage in model.filteredCollages) {
      precacheImage(FileImage(File(collage.imagePath)), context);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchAppBar(
        title: AppLocalizations.of(context).myCollages,
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
        onAdd: () => runtime.dispatch(NavigateToCreateCollage()),
      ),
      body: Column(
        children: [
          if (model.isTagFilterVisible && model.availableTags.isNotEmpty)
            _buildTagFilterBar(model),
          Expanded(
            child: _buildBody(model),
          ),
        ],
      ),
    );
  }

  Widget _buildTagFilterBar(CollagesModel model) {
    final runtime = Runtime(context, ref);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.selectedTags.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).activeFilters(model.selectedTags.length),
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.tagText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: Text(AppLocalizations.of(context).clearFilters),
                    onPressed: () {
                      runtime.dispatch(ClearTagFilters());
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
                ],
              ),
            ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: model.availableTags.map((tag) {
              final isSelected = model.selectedTags.contains(tag);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    runtime.dispatch(TagSelected(tag, selected));
                  },
                  selectedColor: AppColors.tagSelected,
                  backgroundColor: AppColors.tagBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  elevation: isSelected ? 2 : 0,
                  shadowColor: AppColors.shadow.withValues(alpha: 0.3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  labelStyle: AppTextStyles.tagText.copyWith(
                    color: isSelected ? Colors.white : AppColors.tagText,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(CollagesModel model) {
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

    return CollagesGrid(collages: model.filteredCollages);
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
