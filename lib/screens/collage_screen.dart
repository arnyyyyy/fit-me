import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../widgets/positioned_draggable_image.dart';
import '../widgets/checkerboard_painter.dart';
import '../services/image_service.dart';

class CollageScreen extends StatefulWidget {
  const CollageScreen({super.key});

  @override
  _CollageScreenState createState() => _CollageScreenState();
}

class _CollageScreenState extends State<CollageScreen> {
  final List<File> _images = [];
  final ImagePicker _picker = ImagePicker();
  final GlobalKey _stackKey = GlobalKey();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadSavedImages();
  }

  Future<void> _loadSavedImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final processedDir = Directory('${appDir.path}/processed_images');
    
    if (await processedDir.exists()) {
      final files = await processedDir.list().toList();
      for (final file in files) {
        if (file is File) {
          await file.delete();
        }
      }
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

  Future<void> _removeBackground(File imageFile) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final imageService = ImageService();
      final processedFilePath = await imageService.removeBackground(imageFile);
      
      setState(() {
        final index = _images.indexOf(imageFile);
        if (index != -1) {
          print('Updating image at index $index from ${_images[index].path} to $processedFilePath');
          _images[index] = File(processedFilePath);
        } else {
          print('Image not found in list: ${imageFile.path}');
        }
      });

      await Share.shareXFiles([XFile(processedFilePath)], text: 'Изображение без фона');

    } catch (e) {
      print('Error in background removal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
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

      await Share.shareXFiles([XFile(imagePath)], text: 'My Collage');

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
        ],
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _stackKey,
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    image: null,
                  ),
                  child: CustomPaint(
                    painter: CheckerboardPainter(),
                    size: Size.infinite,
                  ),
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
                    onRemoveBackground: () => _removeBackground(_images[i]),
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
        onPressed: _pickImage,
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}