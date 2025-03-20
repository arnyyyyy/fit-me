import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CollageApp(),
    );
  }
}

class CollageApp extends StatefulWidget {
  const CollageApp({super.key});

  @override
  _CollageAppState createState() => _CollageAppState();
}

class _CollageAppState extends State<CollageApp> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    if (_images.length >= 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Load max 6 photos')),
      );
      return;
    }

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _bringToFront(int index) {
    setState(() {
      final image = _images.removeAt(index);
      _images.add(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo of collage creation'),
      ),
      body: Stack(
        children: [
          Container(color: Colors.grey[200]),
          for (int i = 0; i < _images.length; i++)
            PositionedDraggableImage(
              key: ValueKey(_images[i]),
              image: _images[i],
              onDelete: () {
                setState(() {
                  _images.removeAt(i);
                });
              },
              onTap: () => _bringToFront(i),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class PositionedDraggableImage extends StatefulWidget {
  final File image;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const PositionedDraggableImage({
    required this.image,
    required this.onDelete,
    required this.onTap,
    super.key,
  });

  @override
  _PositionedDraggableImageState createState() =>
      _PositionedDraggableImageState();
}

class _PositionedDraggableImageState extends State<PositionedDraggableImage> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    const double minSize = 150.0;
    const double maxSize = 450.0;
    final double imageSize = (minSize * _scale).clamp(minSize, maxSize);

    return Positioned(
      left: _offset.dx,
      top: _offset.dy,
      child: GestureDetector(
        onScaleStart: (details) {
          _previousScale = _scale;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scale = (_previousScale * details.scale).clamp(0.001, 3.0);
            _offset += details.focalPointDelta;

            _offset = Offset(
              _offset.dx.clamp(0.0, screenSize.width - imageSize),
              _offset.dy
                  .clamp(0.0, screenSize.height - imageSize - kToolbarHeight),
            );
          });
        },
        onScaleEnd: (details) {},
        onTap: widget.onTap,
        onLongPress: widget.onDelete,
        child: Transform.scale(
          scale: _scale,
          child: Image.file(
            widget.image,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
