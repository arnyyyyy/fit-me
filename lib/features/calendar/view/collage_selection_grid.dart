import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../collages/model/saved_collage.dart';

class CollageSelectionGrid extends StatelessWidget {
  final List<SavedCollage> collages;
  final Function(SavedCollage) onCollageSelected;
  final Function() onCancel;

  const CollageSelectionGrid({
    super.key,
    required this.collages,
    required this.onCollageSelected,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).selectCollage,
                  style: AppTextStyles.title,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onCancel,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).selectCollageHint,
              style: AppTextStyles.body.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: collages.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context).noCollages,
                        style: AppTextStyles.emptyText,
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: collages.length,
                      itemBuilder: (context, index) {
                        final collage = collages[index];
                        return GestureDetector(
                          onTap: () => onCollageSelected(collage),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.clothesCardBackground,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.cardBackground,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.file(
                                    File(collage.imagePath),
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    collage.name,
                                    style: AppTextStyles.imageTitle,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
