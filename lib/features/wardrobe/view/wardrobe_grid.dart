import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/saved_image.dart';
import '../message/message.dart';
import 'clothes_card.dart';

class WardrobeGrid extends ConsumerWidget {
  final List<SavedImage> images;
  final Function(Message) onMessage;

  const WardrobeGrid({
    super.key, 
    required this.images,
    required this.onMessage,
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
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ClothesCard(
          savedImage: images[index],
          onMessage: onMessage,
        );
      },
    );
  }
}
