import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../collages/model/saved_collage.dart';
import '../model/model.dart';

class EventCollagesView extends StatelessWidget {
  final CalendarEventDay event;
  final Function(int) onRemoveCollage;
  final Function() onAddCollage;
  final Function(SavedCollage)? onOpenCollage;

  const EventCollagesView({
    Key? key,
    required this.event,
    required this.onRemoveCollage,
    required this.onAddCollage,
    this.onOpenCollage, // Необязательный параметр
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).collages,
          style: AppTextStyles.subtitle,
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 0, maxHeight: constraints.maxHeight),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (int i = 0; i < event.collages.length; i++)
                        if (event.collages[i] != null)
                          _buildCollageItem(context, event.collages[i]!, i),
                      
                      if (event.collageCount < CalendarEventDay.maxCollages)
                        _buildAddCollageButton(context),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildCollageItem(BuildContext context, SavedCollage collage, int index) {
    final itemWidth = 100.0;
    final itemHeight = 120.0;
    
    return Stack(
      children: [
        GestureDetector(
          onTap: onOpenCollage != null ? () => onOpenCollage!(collage) : null,
          child: Container(
            width: itemWidth,
            height: itemHeight,
            decoration: BoxDecoration(
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
                    height: 80,
                    width: itemWidth,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4, right: 6),
                    child: Text(
                      collage.name,
                      style: AppTextStyles.imageTitle.copyWith(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => onRemoveCollage(index),
            child: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Colors.brown,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCollageButton(BuildContext context) {
    final itemWidth = 100.0;
    final itemHeight = 120.0;
    
    return GestureDetector(
      onTap: onAddCollage,
      child: Container(
        width: itemWidth,
        height: itemHeight,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: AppColors.primary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                AppLocalizations.of(context).addCollage,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
