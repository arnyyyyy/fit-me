import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import '../../../widgets/positioned_draggable_image.dart';
import '../../../widgets/checkerboard_painter.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../effect/runtime.dart';
import '../message/message.dart';
import '../model/model.dart';
import 'clothes_picker_screen.dart';

class CollageConstructorScreen extends ConsumerStatefulWidget {
  const CollageConstructorScreen({super.key});

  @override
  ConsumerState<CollageConstructorScreen> createState() => _CollageConstructorScreen();
}

class _CollageConstructorScreen extends ConsumerState<CollageConstructorScreen> {
  final GlobalKey _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final runtime = CollagesRuntime(context, ref);
    runtime.dispatch(InitCollageScreen());
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(collagesModelProvider);
    final runtime = CollagesRuntime(context, ref);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('collage studio', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => runtime.captureCollageImage(_stackKey),
          ),
          PopupMenuButton<CollageBackground>(
            icon: const Icon(Icons.layers),
            onSelected: (value) {
              runtime.dispatch(ChangeCollageBackground(value));
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: CollageBackground.transparent,
                child: Text("прозрачный фон"),
              ),
              PopupMenuItem(
                value: CollageBackground.white,
                child: Text("белый фон"),
              ),
              PopupMenuItem(
                value: CollageBackground.black,
                child: Text("чёрный фон"),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _stackKey,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: model.selectedBackground == CollageBackground.transparent
                    ? null
                    : (model.selectedBackground == CollageBackground.white
                        ? Colors.white
                        : Colors.black),
              ),
              child: Stack(
                children: [
                  if (model.selectedBackground == CollageBackground.transparent)
                    CustomPaint(
                      painter: CheckerboardPainter(),
                      size: Size.infinite,
                    ),
                  ...model.images.asMap().entries.map((entry) {
                    int index = entry.key;
                    File image = entry.value;
                    return PositionedDraggableImage(
                      key: ValueKey(image.path + image.hashCode.toString()),
                      image: image,
                      onDelete: () {
                        runtime.dispatch(RemoveImageFromCollage(index));
                      },
                      onTap: () => runtime.dispatch(BringImageToFront(index)),
                    );
                  }),
                ],
              ),
            ),
          ),
          if (model.isProcessing)
            Container(
              color: Colors.black.withAlpha(128),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final runtime = CollagesRuntime(context, ref);
          final images = await runtime.loadSavedImages();
          if (context.mounted) {
            final selectedImages = await Navigator.push<List<File>>(
              context,
              MaterialPageRoute(
                builder: (_) => ClothesPickerScreen(images: images),
              ),
            );

            if (selectedImages != null && selectedImages.isNotEmpty) {
              runtime.dispatch(AddImagesToCollage(selectedImages));
            }
          }
        },
        icon: const Icon(Icons.add_photo_alternate_outlined,
            color: AppColors.tagText),
        label:
            const Text("добавить", style: TextStyle(color: AppColors.tagText)),
        backgroundColor: AppColors.background,
      ),
    );
  }
}
