import 'package:flutter/cupertino.dart';

import '../models/saved_image.dart';
import 'clothes_card.dart';

class ClothesGrid extends StatelessWidget {
  final List<SavedImage> images;

  const ClothesGrid({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
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
        return ClothesCard(savedImage: images[index]);
      },
    );
  }
}
