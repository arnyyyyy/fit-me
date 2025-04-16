import 'dart:typed_data';
import 'dart:io';

import 'package:fit_me/screens/tags.dart';
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

  List<String> _allTags = [];
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final box = await Hive.openBox<SavedImage>('imagesBox');
    final allImages = box.values.toList();
    final Set<String> tagsSet = {};
    for (final image in allImages) {
      tagsSet.addAll(image.tags);
    }
    setState(() {
      _allTags = tagsSet.toList()..sort();
    });
  }


  Future<void> _saveImage() async {
    final name = _nameController.text.trim();
    final tags = _selectedTags;

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.memory(widget.imageBytes, height: 200),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Название"),
            ),
            const SizedBox(height: 16),
            TagSelectorWidget(
              initialTags: _selectedTags,
              allAvailableTags: _allTags,
              onTagsChanged: (tags) {
                setState(() {
                  _selectedTags = tags;
                });
              },
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
