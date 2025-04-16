import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../saved_image.dart';
import '../widgets/positioned_draggable_image.dart';
import '../widgets/checkerboard_painter.dart';
import 'collage_meta_screen.dart';

enum CollageBackground {
  transparent,
  white,
  black,
}



class CollageScreen extends StatefulWidget {
  const CollageScreen({super.key});

  @override
  _CollageScreenState createState() => _CollageScreenState();
}

class _CollageScreenState extends State<CollageScreen> {
  CollageBackground _background = CollageBackground.transparent;


  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _stackKey = GlobalKey();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<List<File>> _loadSavedImages() async {
    final box = await Hive.openBox<SavedImage>('imagesBox');
    final List<SavedImage> savedImages = box.values.toList();

    return savedImages.map((img) => File(img.imagePath)).toList();
  }

  Future<void> _openImageSelectionScreen() async {
    final images = await _loadSavedImages();

    final selected = await Navigator.push<List<File>>(
      context,
      MaterialPageRoute(
        builder: (_) => _ImagePickerFromHive(images: images),
      ),
    );

    if (selected != null) {
      setState(() {
        _images.addAll(selected.where((img) => !_images.contains(img)));
      });
    }
  }



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


  Future<void> _saveCollage() async {
    try {
      RenderRepaintBoundary boundary = _stackKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/collage.png';
      File imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CollageMetaScreen(collageBytes: pngBytes),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collage shared successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share collage: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo of collage creation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCollage,
          ),
          PopupMenuButton<CollageBackground>(
            icon: const Icon(Icons.layers),
            onSelected: (value) {
              setState(() {
                _background = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: CollageBackground.transparent,
                child: Text("Прозрачный фон"),
              ),
              const PopupMenuItem(
                value: CollageBackground.white,
                child: Text("Белый фон"),
              ),
              const PopupMenuItem(
                value: CollageBackground.black,
                child: Text("Чёрный фон"),
              ),
            ],
          ),

        ],
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _stackKey,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: _background == CollageBackground.transparent
                        ? null
                        : (_background == CollageBackground.white ? Colors.white : Colors.black),
                  ),
                  child: _background == CollageBackground.transparent
                      ? CustomPaint(
                    painter: CheckerboardPainter(),
                    size: Size.infinite,
                  )
                      : null,
                ),

                for (int i = 0; i < _images.length; i++)
                  PositionedDraggableImage(
                    key: ValueKey(_images[i].path),
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
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openImageSelectionScreen,
        child: const Icon(Icons.add_photo_alternate),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _ImagePickerFromHive extends StatefulWidget {
  final List<File> images;

  const _ImagePickerFromHive({required this.images});

  @override
  State<_ImagePickerFromHive> createState() => _ImagePickerFromHiveState();
}

class _ImagePickerFromHiveState extends State<_ImagePickerFromHive> {
  final Set<File> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Выбери изображения"),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () => Navigator.pop(context, _selected.toList()),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          final file = widget.images[index];
          final isSelected = _selected.contains(file);

          return GestureDetector(
            onTap: () {
              setState(() {
                isSelected ? _selected.remove(file) : _selected.add(file);
              });
            },
            child: Stack(
              children: [
                Image.file(file, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                if (isSelected)
                  Container(
                    color: Colors.black45,
                    child: const Center(
                      child: Icon(Icons.check_circle, color: Colors.white, size: 40),
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
