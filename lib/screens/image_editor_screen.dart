import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/saved_image.dart';
import '../providers/hive_providers.dart';
import '../services/image_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'image_meta_screen.dart';

class ImageEditorScreen extends ConsumerStatefulWidget {
  final Uint8List imageBytes;

  const ImageEditorScreen({super.key, required this.imageBytes});

  @override
  ConsumerState<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends ConsumerState<ImageEditorScreen> {
  ui.Image? _image;
  late ui.Image _originalImage;
  late ui.Image _originalImageBeforeRemoveBg;

  final List<ErasePoint> _points = [];

  double _brushRadius = 25.0;
  late double _scale;
  late Offset _imageOffset;
  bool _isErasing = true;

  @override
  void initState() {
    super.initState();
    _loadImage(widget.imageBytes);
  }

  Future<void> _loadImage(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
      _originalImage = frame.image;
      _originalImageBeforeRemoveBg = frame.image;
    });
  }

  void _handlePan(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    final imagePosition = (localPosition - _imageOffset) / _scale;

    setState(() {
      _points.add(ErasePoint(imagePosition, _isErasing, _brushRadius));
    });
  }


  Future<Uint8List> _generateEditedImageBytes() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(_originalImage, Offset.zero, Paint());

    for (final p in _points) {
      if (p.isErase) {
        final paint = Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p.point, p.radius, paint);
      } else {
        final srcRect = Rect.fromCenter(
          center: p.point,
          width: p.radius * 2,
          height: p.radius * 2,
        );
        canvas.drawImageRect(
          _originalImageBeforeRemoveBg,
          srcRect,
          srcRect,
          Paint(),
        );
      }
    }

    final renderedImage = await recorder.endRecording().toImage(_image!.width, _image!.height);
    final byteData = await renderedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _saveEditedImage() async {
    final editedBytesFuture = _generateEditedImageBytes();

    if (!mounted) return;

    // Переходим на следующий экран, сразу передав Future для обработки изображения
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImageMetaScreen(imageBytesFuture: editedBytesFuture),
      ),
    );
  }




  Future<void> _removeBackgroundAndUpdate() async {
    final pngBytes = await _generateEditedImageBytes();
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_image.png');
    await tempFile.writeAsBytes(pngBytes);

    final service = ImageService();
    final noBgPath = await service.removeBackground(tempFile);
    final noBgBytes = await File(noBgPath).readAsBytes();
    final codec = await ui.instantiateImageCodec(noBgBytes);
    final frame = await codec.getNextFrame();

    setState(() {
      _originalImage = frame.image;
      _image = frame.image;
      _points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактор", style: AppTextStyles.title),
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveEditedImage),
          IconButton(
            icon: const Icon(Icons.auto_fix_high),
            tooltip: "Удалить фон",
            onPressed: _image == null
                ? null
                : () async {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
              try {
                await _removeBackgroundAndUpdate();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Ошибка удаления фона: $e')),
                );
              } finally {
                Navigator.pop(context);
              }
            },
          ),
          IconButton(
            icon: Icon(_isErasing ? Icons.remove : Icons.add),
            onPressed: () {
              setState(() {
                _isErasing = !_isErasing;
              });
            },
          ),
        ],
      ),
      body: _image == null
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
        builder: (context, constraints) {
          final imgWidth = _image!.width.toDouble();
          final imgHeight = _image!.height.toDouble();
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
                  child: CustomPaint(
                    painter: EraserPainter(
                      originalImage: _originalImage,
                      restoreImage: _originalImageBeforeRemoveBg,
                      points: _points,
                      scale: _scale,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Размер кисти",
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            Slider(
              value: _brushRadius,
              min: 5,
              max: 100,
              divisions: 19,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withAlpha(76),
              label: _brushRadius.round().toString(),
              onChanged: (value) {
                setState(() {
                  _brushRadius = value;
                });
              },
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

    final bgPaint = Paint()..color = Colors.black;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, originalImage.width.toDouble(), originalImage.height.toDouble()),
      bgPaint,
    );

    canvas.drawImage(originalImage, Offset.zero, Paint());

    for (final p in points) {
      if (p.isErase) {
        final paint = Paint()
          ..blendMode = BlendMode.clear
          ..style = PaintingStyle.fill;
        canvas.drawCircle(p.point, p.radius, paint);
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

class ErasePoint {
  final Offset point;
  final bool isErase;
  final double radius;

  ErasePoint(this.point, this.isErase, this.radius);
}


Future<void> saveImageWithMeta({
  required Uint8List imageBytes,
  required String name,
  required List<String> tags,
  required WidgetRef ref,
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final imagePath = '${dir.path}/$name.png';

  final file = File(imagePath);
  await file.writeAsBytes(imageBytes);

  final image = SavedImage(name: name, imagePath: imagePath, tags: tags);
  
  // Используем провайдер для сохранения изображения
  await ref.read(imageOperationsProvider).addImage(image);
}
