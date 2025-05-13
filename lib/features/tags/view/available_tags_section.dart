import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

class AvailableTagsSection extends StatelessWidget {
  final List<String> availableTags;
  final ValueChanged<String> onTagSelected;

  const AvailableTagsSection({
    super.key,
    required this.availableTags,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (availableTags.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: Text(
          AppLocalizations.of(context).noAvailableTags,
          style: const TextStyle(
              color: AppColors.emptyText, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).availableTags,
          style: AppTextStyles.subtitle.copyWith(color: Colors.black),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            return GestureDetector(
              onTap: () => onTagSelected(tag),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.tagBackground,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.1),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  tag,
                  style: AppTextStyles.tagText.copyWith(
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
