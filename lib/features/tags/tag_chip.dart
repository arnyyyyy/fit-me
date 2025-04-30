import 'package:flutter/cupertino.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class TagChip extends StatelessWidget {
  final String label;
  final bool isMoreTag;

  const TagChip({
    super.key,
    required this.label,
    this.isMoreTag = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMoreTag
            ? AppColors.moreTagBackground
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: AppTextStyles.tagText,
      ),
    );
  }
}
