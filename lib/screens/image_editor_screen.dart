import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageEditorScreen extends StatefulWidget {
  final File imageFile;

  const ImageEditorScreen({super.key, required this.imageFile});

  @override
  State<ImageEditorScreen> createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  ui.Image? _image;
  final List<Offset> _points = [];
  final List<Offset> _undonePoints = [];
  final double _brushRadius = 25.0;

  late double _scale;
  late Offset _imageOffset;

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
    });
  }

  void _handlePan(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);

    final imagePosition = (localPosition - _imageOffset) / _scale;

    setState(() {
      _points.add(imagePosition);
    });
  }

  void _undo() {
    if (_points.isNotEmpty) {
      setState(() {
        _undonePoints.add(_points.removeLast());
      });
    }
  }

  void _redo() {
    if (_undonePoints.isNotEmpty) {
      setState(() {
        _points.add(_undonePoints.removeLast());
      });
    }
  }

  Future<Uint8List> _generateEditedImageBytes() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawImage(_image!, Offset.zero, Paint());

    for (final point in _points) {
      final clearPaint = Paint()
        ..blendMode = BlendMode.clear
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, _brushRadius, clearPaint);
    }

    final renderedImage =
        await recorder.endRecording().toImage(_image!.width, _image!.height);
    final byteData =
        await renderedImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  Future<void> _shareEditedImage() async {
    final pngBytes = await _generateEditedImageBytes();
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/shared_image.png').create();
    await file.writeAsBytes(pngBytes);

    await Share.shareXFiles([XFile(file.path)]);
  }

  Future<void> _saveEditedImage() async {
    final pngBytes = await _generateEditedImageBytes();
    print('Сохранено изображение, байт: ${pngBytes.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Редактор"),
        actions: [
          IconButton(icon: const Icon(Icons.undo), onPressed: _undo),
          IconButton(icon: const Icon(Icons.redo), onPressed: _redo),
          IconButton(icon: const Icon(Icons.save), onPressed: _saveEditedImage),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _image == null ? null : _shareEditedImage,
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
                            image: _image!,
                            points: _points,
                            brushRadius: _brushRadius,
                            scale: _scale,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class EraserPainter extends CustomPainter {
  final ui.Image image;
  final List<Offset> points;
  final double brushRadius;
  final double scale;

  EraserPainter({
    required this.image,
    required this.points,
    required this.brushRadius,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale);
    canvas.drawImage(image, Offset.zero, Paint());

    final clearPaint = Paint()
      ..blendMode = BlendMode.clear
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, brushRadius, clearPaint);
    }
  }

  @override
  bool shouldRepaint(EraserPainter oldDelegate) => oldDelegate.points != points;
}
