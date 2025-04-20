import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../models/saved_image.dart';
import '../widgets/positioned_draggable_image.dart';
import '../widgets/checkerboard_painter.dart';
import 'collage_meta_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

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

  Future<List<File>> _loadSavedImages() async {
    final box = await Hive.openBox<SavedImage>('imagesBox');
    return box.values.map((img) => File(img.imagePath)).toList();
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
        const SnackBar(content: Text('максимум 6 фотографий')),
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
      setState(() => _isProcessing = true);
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('не удалось сохранить: $e')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('collage studio', style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: _saveCollage,
          ),
          PopupMenuButton<CollageBackground>(
            icon: const Icon(Icons.layers),
            onSelected: (value) {
              setState(() => _background = value);
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
                color: _background == CollageBackground.transparent
                    ? null
                    : (_background == CollageBackground.white ? Colors.white : Colors.black),
              ),
              child: Stack(
                children: [
                  if (_background == CollageBackground.transparent)
                    CustomPaint(
                      painter: CheckerboardPainter(),
                      size: Size.infinite,
                    ),
                  ..._images.asMap().entries.map((entry) {
                    int index = entry.key;
                    File image = entry.value;
                    return PositionedDraggableImage(
                      key: ValueKey(image.path),
                      image: image,
                      onDelete: () {
                        setState(() => _images.removeAt(index));
                      },
                      onTap: () => _bringToFront(index),
                    );
                  }),
                ],
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openImageSelectionScreen,
        icon: const Icon(Icons.add_photo_alternate_outlined, color:AppColors.tagText),
        label: const Text("добавить", style: TextStyle(color:AppColors.tagText),),
        backgroundColor: AppColors.background,
      ),
    );
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("выбери фото", style: AppTextStyles.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            onPressed: () => Navigator.pop(context, _selected.toList()),
          )
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
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
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(file, fit: BoxFit.cover),
                ),
                if (isSelected)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.check_circle, color: Colors.white, size: 36),
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
