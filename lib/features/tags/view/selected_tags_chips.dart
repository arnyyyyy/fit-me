import 'package:flutter/material.dart';
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
      return const SizedBox(
        width: double.infinity,
        child: Text(
          'Нет выбранных тегов',
          style: TextStyle(
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
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: AppColors.tagSelected,
            deleteIconColor: Colors.white.withValues(alpha: 0.9),
            deleteIcon: const Icon(Icons.close, size: 16),
            onDeleted: () => onTagRemoved(tag),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
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
