import 'dart:io';

import 'package:fit_me/features/tags/view/tag_chip.dart';
import 'package:fit_me/widgets/action_buttons.dart';
import 'package:flutter/material.dart';

import '../model/saved_collage.dart';
import '../message/message.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

class CollageCard extends StatefulWidget {
  final SavedCollage savedCollage;
  final Function(Message) onMessage;
  final bool disableActions;

  const CollageCard({
    super.key,
    required this.savedCollage,
    required this.onMessage,
    this.disableActions = false,
  });

  @override
  State<CollageCard> createState() => _CollageCardState();
}

class _CollageCardState extends State<CollageCard> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    final tags = widget.savedCollage.tags;
    final visibleTags = tags.take(2).toList();
    final hiddenCount = tags.length - visibleTags.length;

    return GestureDetector(
      onLongPress: widget.disableActions
          ? null
          : () {
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
                  child: Image.file(
                    File(widget.savedCollage.imagePath),
                    width: double.infinity,
                    height: 205,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            widget.savedCollage.name.toLowerCase(),
                            style: AppTextStyles.imageTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Wrap(
                          spacing: -7,
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
            if (_showActions && !widget.disableActions)
              ActionsPanel(
                onDismiss: () => setState(() => _showActions = false),
                onEdit: () {
                  setState(() => _showActions = false);
                  widget.onMessage(EditCollage(widget.savedCollage));
                },
                onDelete: () {
                  setState(() => _showActions = false);
                  widget.onMessage(ShowDeleteConfirmation(widget.savedCollage));
                },
              ),
          ],
        ),
      ),
    );
  }
}
