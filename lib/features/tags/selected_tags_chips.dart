import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

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
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: selectedTags.map((tag) {
        return Chip(
          label: Text(tag, style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.accent,
          deleteIconColor: Colors.white,
          onDeleted: () => onTagRemoved(tag),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }).toList(),
    );
  }
}
