import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

class TagChip extends StatelessWidget {
  final String label;
  final bool isMoreTag;
  final VoidCallback? onDeleted;

  const TagChip({
    super.key,
    required this.label,
    this.isMoreTag = false,
    this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            label,
            style: isMoreTag
                ? AppTextStyles.tagText.copyWith(fontWeight: FontWeight.w900)
                : AppTextStyles.tagText,
          ),
          if (onDeleted != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onDeleted,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: AppColors.tagText.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  size: 12,
                  color: AppTextStyles.tagText.color,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
