import 'dart:io';

import 'package:fit_me/features/tags/view/tag_chip.dart';
import 'package:fit_me/widgets/action_buttons.dart';
import 'package:flutter/material.dart';
import '../model/saved_image.dart';
import '../message/message.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

class ClothesCard extends StatefulWidget {
  final SavedImage savedImage;
  final Function(Message) onMessage;

  const ClothesCard({
    super.key,
    required this.savedImage,
    required this.onMessage,
  });

  @override
  State<ClothesCard> createState() => _ClothesCardState();
}

class _ClothesCardState extends State<ClothesCard> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final tags = widget.savedImage.tags;
    final visibleTags = tags.take(2).toList();
    final hiddenCount = tags.length - visibleTags.length;

    return GestureDetector(
      onTap: () {
        widget.onMessage(ViewClothesItem(widget.savedImage));
      },
      onLongPress: () {
        setState(() {
          _showActions = true;
        });
      },
      child: Container(
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
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Hero(
                    tag: 'clothes_image_${widget.savedImage.imagePath}',
                    child: Image.file(
                      File(widget.savedImage.imagePath),
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            widget.savedImage.name.toLowerCase(),
                            style: AppTextStyles.imageTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Wrap(
                          spacing: 6,
                          runSpacing: -4,
                          children: [
                            for (var tag in visibleTags) TagChip(label: tag),
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
            if (_showActions)
              ActionsPanel(
                onDismiss: () => setState(() => _showActions = false),
                onEdit: () {
                  setState(() => _showActions = false);
                  widget.onMessage(EditImage(widget.savedImage));
                },
                onDelete: () {
                  setState(() => _showActions = false);
                  widget.onMessage(ShowDeleteConfirmation(widget.savedImage));
                },
              ),
          ],
        ),
      ),
    );
  }
}
