import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/saved_collage.dart';
import '../message/message.dart';
import 'collage_card.dart';

class CollagesGrid extends ConsumerWidget {
  final List<SavedCollage> collages;
  final Function(Message) onMessage;
  final bool selectionMode;
  final Function(SavedCollage)? onCollageSelected;

  const CollagesGrid({
    super.key, 
    required this.collages,
    required this.onMessage,
    this.selectionMode = false,
    this.onCollageSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 3 / 4.5,
      ),
      itemCount: collages.length,
      itemBuilder: (context, index) {
        final savedCollage = collages[index];
        
        if (selectionMode) {
          return GestureDetector(
            onTap: () => onCollageSelected?.call(savedCollage),
            child: CollageCard(
              savedCollage: savedCollage,
              onMessage: onMessage,
              disableActions: true,
            ),
          );
        }
        
        return CollageCard(
          savedCollage: savedCollage,
          onMessage: onMessage,
        );
      },
    );
  }
}
