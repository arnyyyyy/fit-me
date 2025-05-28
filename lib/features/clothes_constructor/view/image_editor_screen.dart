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
  bool _isImageLoaded = false;
  bool _loadingTooLong = false;
  double _lastScaleFactor = 1.0;
  Offset _lastFocalPoint = Offset.zero;
  Offset _startUserOffset = Offset.zero;

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

  Offset _getActualOffset(ImageConstructorModel model) {
    if (model.currentImage == null) return Offset.zero;
    
    final imgWidth = model.currentImage!.width.toDouble();
    final imgHeight = model.currentImage!.height.toDouble();
    final renderBox = context.findRenderObject() as RenderBox;
    final constraints = renderBox.constraints;
    
    final actualScale = _scale * model.userScale;
    final actualWidth = imgWidth * actualScale;
    final actualHeight = imgHeight * actualScale;
    
    return Offset(
      (constraints.maxWidth - actualWidth) / 2 + model.userOffset.dx,
      (constraints.maxHeight - actualHeight) / 2 + model.userOffset.dy,
    );
  }
  
  void _handleScaleStart(ScaleStartDetails details) {
    final model = ref.read(imageConstructorModelProvider);
    _lastScaleFactor = model.userScale;
    _lastFocalPoint = details.focalPoint;
    _startUserOffset = model.userOffset;
  }
  
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    final model = ref.read(imageConstructorModelProvider);
    if (model.currentImage == null) return;
    final runtime = ImageConstructorRuntime(context, ref);

    if (details.pointerCount > 1) {
      if (details.scale != 1.0) {
        final newScale = (_lastScaleFactor * details.scale).clamp(0.5, 5.0);
        runtime.dispatch(ChangeImageScale(newScale));
      }
      final delta = details.focalPoint - _lastFocalPoint;
      final newOffset = Offset(
        _startUserOffset.dx + delta.dx,
        _startUserOffset.dy + delta.dy
      );
      runtime.dispatch(ChangeImageOffset(newOffset));
    } 
    else if (details.pointerCount == 1) {
      final renderBox = context.findRenderObject() as RenderBox;
      final localPosition = renderBox.globalToLocal(details.localFocalPoint);
      final actualScale = _scale * model.userScale;
      final actualOffset = _getActualOffset(model);
      final imagePosition = (localPosition - actualOffset) / actualScale;

      runtime.dispatch(AddErasePoint(imagePosition));
    }
  }
  
  void _handleScaleEnd(ScaleEndDetails details) {
    final model = ref.read(imageConstructorModelProvider);
    _lastScaleFactor = model.userScale;
    _startUserOffset = model.userOffset;
  }
  
  void _handleDoubleTap() {
    final model = ref.read(imageConstructorModelProvider);
    final runtime = ImageConstructorRuntime(context, ref);
    
    if (model.userScale == 1.0) {
      runtime.dispatch(ChangeImageScale(2.0));
    } else {
      runtime.dispatch(ResetImageScale());
      if (model.userOffset != Offset.zero) {
        runtime.dispatch(ResetImageOffset());
      }
    }
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
          if (model.userScale != 1.0)
            IconButton(
              icon: const Icon(Icons.zoom_out_map),
              tooltip: "Сбросить масштаб",
              onPressed: model.isProcessingImage || !_isImageLoaded
                  ? null
                  : () => runtime.dispatch(ResetImageScale()),
            ),
          if (model.userOffset != Offset.zero)
            IconButton(
              icon: const Icon(Icons.center_focus_strong),
              tooltip: "Центрировать изображение",
              onPressed: model.isProcessingImage || !_isImageLoaded
                  ? null
                  : () => runtime.dispatch(ResetImageOffset()),
            ),
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
                final actualScale = _scale * model.userScale;
                final actualWidth = imgWidth * actualScale;
                final actualHeight = imgHeight * actualScale;
                
                final actualOffset = _getActualOffset(model);
                
                return GestureDetector(
                  onScaleStart: model.isProcessingImage ? null : _handleScaleStart,
                  onScaleUpdate: model.isProcessingImage ? null : _handleScaleUpdate,
                  onScaleEnd: model.isProcessingImage ? null : _handleScaleEnd,
                  onDoubleTap: model.isProcessingImage ? null : _handleDoubleTap,
                  child: Stack(
                    children: [
                      Positioned(
                        left: actualOffset.dx,
                        top: actualOffset.dy,
                        width: actualWidth,
                        height: actualHeight,
                        child: Container(color: Colors.white),
                      ),
                      Positioned(
                        left: actualOffset.dx,
                        top: actualOffset.dy,
                        width: actualWidth,
                        height: actualHeight,
                        child: CustomPaint(
                          key: _canvasKey,
                          painter: EraserPainter(
                            originalImage: model.originalImage!,
                            restoreImage: model.originalImageBeforeRemoveBg!,
                            points: model.erasePoints,
                            scale: actualScale,
                          ),
                        ),
                      ),
                      if (model.userScale != 1.0 || model.userOffset != Offset.zero)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(model.userScale * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (model.userOffset != Offset.zero)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4.0),
                                    child: Icon(
                                      Icons.open_with,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                              ],
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
