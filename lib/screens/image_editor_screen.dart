import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

import '../saved_image.dart';
import 'image_meta_screen.dart';


class ImageEditorScreen extends StatefulWidget {
  final File imageFile;

  const ImageEditorScreen({super.key, required this.imageFile});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  ui.Image? _image;
  late ui.Image _originalImage;

  final List<ErasePoint> _points = [];

  double _brushRadius = 25.0;

  late double _scale;
  late Offset _imageOffset;
  bool _isErasing = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final data = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    setState(() {
      _image = frame.image;
      _originalImage = frame.image;
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

        final dstRect = srcRect;

        canvas.drawImageRect(
          _originalImage,
          srcRect,
          dstRect,
          Paint(),
        );
      }
    }

    final renderedImage =
        await recorder.endRecording().toImage(_image!.width, _image!.height);
    final byteData =
        await renderedImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<void> _saveEditedImage() async {
    await _generateEditedImageBytes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактор"),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveEditedImage),
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _image == null
                ? null
                : () async {
              final imageBytes = await _generateEditedImageBytes();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ImageMetaScreen(imageBytes: imageBytes),
                ),
              );
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
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Размер кисти"),
            Slider(
              value: _brushRadius,
              min: 5,
              max: 100,
              divisions: 19,
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
  final List<ErasePoint> points;
  final double scale;

  EraserPainter({
    required this.originalImage,
    required this.points,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);

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

        final dstRect = srcRect;

        canvas.drawImageRect(
          originalImage,
          srcRect,
          dstRect,
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
}) async {
  final dir = await getApplicationDocumentsDirectory();
  final imagePath = '${dir.path}/$name.png';

  final file = File(imagePath);
  await file.writeAsBytes(imageBytes);

  final box = Hive.box<SavedImage>('imagesBox');
  final image = SavedImage(name: name, imagePath: imagePath, tags: tags);
  await box.add(image);
}
