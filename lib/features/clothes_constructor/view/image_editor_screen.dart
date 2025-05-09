import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../effect/runtime.dart';
import '../message/message.dart';
import '../model/model.dart';

class ImageEditorScreen extends ConsumerStatefulWidget {
  final Uint8List imageBytes;

  const ImageEditorScreen({super.key, required this.imageBytes});

  @override
  ConsumerState<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends ConsumerState<ImageEditorScreen> {
  final GlobalKey _canvasKey = GlobalKey();
  late double _scale;
  late Offset _imageOffset;
  bool _isImageLoaded = false;
  bool _loadingTooLong = false;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadImage();
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isImageLoaded) {
        setState(() {
          _loadingTooLong = true;
        });
      }
    });
  }

  Future<void> _loadImage() async {
    final runtime = ImageConstructorRuntime(context, ref);
    runtime.loadImage(widget.imageBytes);
  }

  void _retryLoading() {
    setState(() {
      _loadingTooLong = false;
    });
    _loadImage();

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && !_isImageLoaded) {
        setState(() {
          _loadingTooLong = true;
        });
      }
    });
  }

  void _handlePan(DragUpdateDetails details) {
    final model = ref.read(imageConstructorModelProvider);
    if (model.currentImage == null) return;

    final runtime = ImageConstructorRuntime(context, ref);
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final imagePosition = (localPosition - _imageOffset) / _scale;

    runtime.dispatch(AddErasePoint(imagePosition));
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(imageConstructorModelProvider);
    final runtime = ImageConstructorRuntime(context, ref);

    if (model.currentImage != null && !_isImageLoaded) {
      setState(() {
        _isImageLoaded = true;
        _loadingTooLong = false;
      });
    }

    final hasError = model.errorMessage != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).editor, style: AppTextStyles.title),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: model.isProcessingImage || !_isImageLoaded
                ? null
                : () => runtime.saveEditedImage(),
          ),
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            tooltip: "Удалить фон",
            onPressed: (model.currentImage == null || model.isProcessingImage)
                ? null
                : () => runtime.removeBackground(),
          ),
          IconButton(
            icon: Icon(model.isErasing ? Icons.remove : Icons.add),
            onPressed: model.isProcessingImage || !_isImageLoaded
                ? null
                : () => runtime.dispatch(ToggleEraseMode()),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (hasError)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.primary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).imageLoadError,
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    model.errorMessage!,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _retryLoading,
                    child: Text(AppLocalizations.of(context).retryButton),
                  ),
                ],
              ),
            )
          else if (_loadingTooLong && !_isImageLoaded)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context).loadingTakesLonger,
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _retryLoading,
                    child: Text(AppLocalizations.of(context).retryButton),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(AppLocalizations.of(context).cancelButton),
                  ),
                ],
              ),
            )
          else if (model.currentImage == null)
            const Center(child: CircularProgressIndicator())
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final imgWidth = model.currentImage!.width.toDouble();
                final imgHeight = model.currentImage!.height.toDouble();
                final scaleX = constraints.maxWidth / imgWidth;
                final scaleY = constraints.maxHeight / imgHeight;

                _scale = scaleX < scaleY ? scaleX : scaleY;
                final displayWidth = imgWidth * _scale;
                final displayHeight = imgHeight * _scale;

                _imageOffset = Offset(
                  (constraints.maxWidth - displayWidth) / 2,
                  (constraints.maxHeight - displayHeight) / 2,
                );

                return GestureDetector(
                  onPanUpdate: _handlePan,
                  child: Stack(
                    children: [
                      Positioned(
                        left: _imageOffset.dx,
                        top: _imageOffset.dy,
                        width: displayWidth,
                        height: displayHeight,
                        child: Container(color: Colors.white),
                      ),
                      Positioned(
                        left: _imageOffset.dx,
                        top: _imageOffset.dy,
                        width: displayWidth,
                        height: displayHeight,
                        child: CustomPaint(
                          key: _canvasKey,
                          painter: EraserPainter(
                            originalImage: model.originalImage!,
                            restoreImage: model.originalImageBeforeRemoveBg!,
                            points: model.erasePoints,
                            scale: _scale,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (model.isProcessingImage && _isImageLoaded)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: model.currentImage == null
          ? null
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).brushSize,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.text,
                    ),
                  ),
                  Slider(
                    value: model.brushRadius,
                    min: 5,
                    max: 100,
                    divisions: 19,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.primary.withValues(alpha: 0.3),
                    label: model.brushRadius.round().toString(),
                    onChanged: model.isProcessingImage
                        ? null
                        : (value) => runtime.dispatch(ChangeBrushSize(value)),
                  ),
                ],
              ),
            ),
    );
  }
}

class EraserPainter extends CustomPainter {
  final ui.Image originalImage;
  final ui.Image restoreImage;
  final List<ErasePoint> points;
  final double scale;

  EraserPainter({
    required this.originalImage,
    required this.restoreImage,
    required this.points,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);

    final width = originalImage.width.toDouble();
    final height = originalImage.height.toDouble();

    final whiteBgPaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height),
      whiteBgPaint,
    );

    canvas.drawImage(originalImage, Offset.zero, Paint());

    for (final p in points) {
      if (p.isErase) {
        final whitePaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p.point, p.radius, whitePaint);
      } else {
        final srcRect = Rect.fromCenter(
          center: p.point,
          width: p.radius * 2,
          height: p.radius * 2,
        );
        canvas.drawImageRect(
          restoreImage,
          srcRect,
          srcRect,
          Paint(),
        );
      }
    }
  }

  @override
  bool shouldRepaint(EraserPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.scale != scale;
}
