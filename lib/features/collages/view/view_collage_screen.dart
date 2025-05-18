import 'dart:io';

import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../model/saved_collage.dart';

class ViewCollageScreen extends StatelessWidget {
  final SavedCollage collage;

  const ViewCollageScreen({
    Key? key,
    required this.collage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          collage.name,
          style: AppTextStyles.appBarTitle,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(collage.imagePath),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Название',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.photo_album, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        collage.name,
                        style: AppTextStyles.body.copyWith(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Теги',
                style: AppTextStyles.subtitle,
              ),
              const SizedBox(height: 8),
              collage.tags.isNotEmpty
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: collage.tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.2),
                                labelStyle: const TextStyle(color: AppColors.primary),
                              ))
                          .toList(),
                    )
                  : Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.label_off_outlined,
                              color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(
                            'Нет тегов',
                            style: AppTextStyles.body.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
