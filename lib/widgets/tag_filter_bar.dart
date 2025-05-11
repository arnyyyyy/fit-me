import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../core/common/base_message.dart';
import '../core/common/base_runtime.dart';

class TagFilterBar<M extends BaseMessage> extends ConsumerWidget {
  final ProviderBase modelProvider;
  final BaseRuntime<M> Function(BuildContext, WidgetRef) runtimeBuilder;
  final Color backgroundColor;
  final Color shadowColor;
  final M Function(String tag, bool isSelected) tagSelectedMessage;
  final M clearFiltersMessage;

  const TagFilterBar({
    super.key,
    required this.modelProvider,
    required this.runtimeBuilder,
    required this.backgroundColor,
    required this.shadowColor,
    required this.tagSelectedMessage,
    required this.clearFiltersMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runtime = runtimeBuilder(context, ref);
    final model = ref.watch(modelProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.1),
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
                    AppLocalizations.of(context)
                        .activeFilters(model.selectedTags.length),
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.tagText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: Text(AppLocalizations.of(context).clearFilters),
                    onPressed: () {
                      runtime.dispatch(clearFiltersMessage);
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
            children: model.availableTags.map<Widget>((tag) {
              final isSelected = model.selectedTags.contains(tag);

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    runtime.dispatch(tagSelectedMessage(tag, selected));
                  },
                  selectedColor: AppColors.tagBackground,
                  backgroundColor: AppColors.tagBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          isSelected ? AppColors.primary : Colors.transparent,
                      width: 0.2,
                    ),
                  ),
                  elevation: isSelected ? 2 : 0,
                  shadowColor: shadowColor.withValues(alpha: 0.3),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  labelStyle: AppTextStyles.tagText.copyWith(
                    color: AppColors.tagText,
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
}
