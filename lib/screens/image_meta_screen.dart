import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../saved_image.dart';

class ImageMetaScreen extends StatefulWidget {
  final Uint8List imageBytes;

  const ImageMetaScreen({super.key, required this.imageBytes});

  @override
  State<ImageMetaScreen> createState() => _ImageMetaScreenState();
}

class _ImageMetaScreenState extends State<ImageMetaScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  Future<void> _saveImage() async {
    final name = _nameController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (name.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$name.png';
    final file = File(filePath);
    await file.writeAsBytes(widget.imageBytes);

    final box = await Hive.openBox<SavedImage>('imagesBox');
    await box.add(SavedImage(name: name, imagePath: filePath, tags: tags));

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Изображение сохранено')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Сохранить изображение")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.memory(widget.imageBytes, height: 200),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Название"),
            ),
            TextField(
              controller: _tagsController,
              decoration:
              const InputDecoration(labelText: "Теги (через запятую)"),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Сохранить"),
              onPressed: _saveImage,
            ),
          ],
        ),
      ),
    );
  }
}
