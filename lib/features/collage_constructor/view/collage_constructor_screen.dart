import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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

  void _showColorPicker(BuildContext context, CollagesRuntime runtime, Color initialColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = initialColor;
        return AlertDialog(
          title: Text(AppLocalizations.of(context).chooseBackgroundColor, style: AppTextStyles.appBarTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColorPicker(
                  pickerColor: selectedColor,
                  onColorChanged: (Color color) {
                    selectedColor = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                  enableAlpha: true,
                  displayThumbColor: true,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).apply),
              onPressed: () {
                runtime.dispatch(ChangeCustomBackgroundColor(selectedColor));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

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
        title: Text(AppLocalizations.of(context).collageStudio, style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: Icon(
              Icons.auto_fix_normal,
              color: model.isEraserMode ? AppColors.primary : null,
            ),
            tooltip: "Eraser",
            onPressed: () {
              runtime.dispatch(ToggleEraserMode(!model.isEraserMode));
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => runtime.captureCollageImage(_stackKey),
          ),
          PopupMenuButton<CollageBackground>(
            icon: const Icon(Icons.layers),
            onSelected: (value) {
              if (value == CollageBackground.custom) {
                _showColorPicker(context, runtime, model.customBackgroundColor);
              } else {
                runtime.dispatch(ChangeCollageBackground(value));
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: CollageBackground.transparent,
                child: Text(AppLocalizations.of(context).transparentBackground),
              ),
              PopupMenuItem(
                value: CollageBackground.white,
                child: Text(AppLocalizations.of(context).whiteBackground),
              ),
              PopupMenuItem(
                value: CollageBackground.black,
                child: Text(AppLocalizations.of(context).blackBackground),
              ),
              PopupMenuItem(
                value: CollageBackground.custom,
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: model.customBackgroundColor,
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(AppLocalizations.of(context).customBackground),
                  ],
                ),
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
                        : model.selectedBackground == CollageBackground.black
                            ? Colors.black
                            : model.customBackgroundColor),
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
                      isEraseMode: model.isEraserMode,
                      eraserSize: model.eraserSize,
                      onDelete: () {
                        runtime.dispatch(RemoveImageFromCollage(index));
                      },
                      onTap: () => runtime.dispatch(BringImageToFront(index)),
                      onMaskUpdated: (imagePath, mask) {
                        runtime.dispatch(UpdateImageMask(imagePath, mask));
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
          if (model.isEraserMode)
            Positioned(
              bottom: 16,
              left: 24,
              right: 24,
              child: Card(
                color: AppColors.cardBackground,
                elevation: 8,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 77), 
                    width: 1
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: AppColors.primary.withValues(alpha: 51),
                      thumbColor: Colors.white,
                      overlayColor: AppColors.primary.withValues(alpha: 26),
                      trackHeight: 10,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
                    ),
                    child: Slider(
                      value: model.eraserSize,
                      min: 5.0,
                      max: 100.0,
                      divisions: 19,
                      onChanged: (double value) {
                        runtime.dispatch(SetEraserSize(value));
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (model.isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 128),
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
              MaterialPageRoute(builder: (context) => ClothesPickerScreen(images: images)),
            );
            if (selectedImages != null && selectedImages.isNotEmpty && context.mounted) {
              runtime.dispatch(AddImagesToCollage(selectedImages));
            }
          }
        },
        icon: const Icon(Icons.add),
        label: Text(AppLocalizations.of(context).add),
      ),
    );
  }
}
