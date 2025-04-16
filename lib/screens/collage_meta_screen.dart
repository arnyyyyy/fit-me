import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../saved_collage.dart';
import '../saved_image.dart';
import '../screens/tags.dart';

class CollageMetaScreen extends StatefulWidget {
  final Uint8List collageBytes;

  const CollageMetaScreen({super.key, required this.collageBytes});

  @override
  State<CollageMetaScreen> createState() => _CollageMetaScreenState();
}

class _CollageMetaScreenState extends State<CollageMetaScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedTags = [];
  List<String> _allTags = [];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    final box = await Hive.openBox<SavedImage>('imagesBox');
    final Set<String> tagsSet = {};
    for (var img in box.values) {
      tagsSet.addAll(img.tags);
    }
    setState(() {
      _allTags = tagsSet.toList()..sort();
    });
  }

  Future<void> _saveCollage() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/$name.png';
    final file = File(path);
    await file.writeAsBytes(widget.collageBytes);

    final box = await Hive.openBox<SavedCollage>('collagesBox');
    await box.add(SavedCollage(name: name, imagePath: path, tags: _selectedTags));


    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Коллаж сохранён')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Сохранить коллаж")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.memory(widget.collageBytes, height: 200),
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
                  _selectedTags.clear();
                  _selectedTags.addAll(tags);
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text("Сохранить"),
              onPressed: _saveCollage,
            ),
          ],
        ),
      ),
    );
  }
}

