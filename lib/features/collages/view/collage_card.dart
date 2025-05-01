import 'dart:io';

import 'package:flutter/material.dart';

import '../model/saved_collage.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../features/tags/view/tag_chip.dart';

class CollageCard extends StatelessWidget {
  final SavedCollage savedCollage;

  const CollageCard({super.key, required this.savedCollage});

  @override
  Widget build(BuildContext context) {
    final tags = savedCollage.tags;
    final visibleTags = tags.take(2).toList();
    final hiddenCount = tags.length - visibleTags.length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.clothesCardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(3, 4),
          ),
        ],
        border: Border.all(color: AppColors.cardBackground, width: 1),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.file(
              File(savedCollage.imagePath),
              width: double.infinity,
              height: 170,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    savedCollage.name.toLowerCase(),
                    style: AppTextStyles.imageTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: -4,
                    children: [
                      for (var tag in visibleTags) TagChip(label: "#$tag"),
                      if (hiddenCount > 0)
                        TagChip(label: "+$hiddenCount", isMoreTag: true),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}