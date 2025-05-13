import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

class SelectedTagsChips extends StatelessWidget {
  final List<String> selectedTags;
  final ValueChanged<String> onTagRemoved;

  const SelectedTagsChips({
    super.key,
    required this.selectedTags,
    required this.onTagRemoved,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedTags.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Text(
          AppLocalizations.of(context).noSelectedTags,
          style: const TextStyle(
              color: AppColors.emptyText, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: selectedTags.map((tag) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Chip(
            label: Text(
              tag,
              style: AppTextStyles.tagText.copyWith(
                color: AppColors.tagText,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: Colors.white,
            deleteIconColor: Colors.white.withValues(alpha: 0.9),
            deleteIcon: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.primary,
            ),
            onDeleted: () => onTagRemoved(tag),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(
                color: AppColors.primary,
                width: 2.0,
              ),
            ),
            elevation: 2,
            shadowColor: AppColors.shadow.withValues(alpha: 0.3),
          ),
        );
      }).toList(),
    );
  }
}
