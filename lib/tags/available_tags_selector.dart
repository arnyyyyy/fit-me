import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class AvailableTagsSection extends StatelessWidget {
  final List<String> tags;
  final ValueChanged<String> onTagSelected;

  const AvailableTagsSection({
    super.key,
    required this.tags,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Существующие теги:",
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags.map((tag) {
            return ActionChip(
              label: Text(tag, style: AppTextStyles.body),
              backgroundColor: AppColors.surface,
              onPressed: () => onTagSelected(tag),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: AppColors.accent.withValues(alpha: 0.2),
            );
          }).toList(),
        ),
      ],
    );
  }
}
