import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/saved_collage.dart';
import '../models/saved_image.dart';
import '../screens/tags.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

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
        const SnackBar(content: Text('коллаж сохранён.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("save collage", style: AppTextStyles.appBarTitle),
        iconTheme: const IconThemeData(color: AppColors.icon),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                widget.collageBytes,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              cursorColor: AppColors.icon,
              style: AppTextStyles.imageTitle,
              decoration: InputDecoration(
                hintText: "collage name...",
                hintStyle: AppTextStyles.emptyText,
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text("tags", style: AppTextStyles.imageTitle),
            const SizedBox(height: 8),
            TagSelectorWidget(
              initialTags: _selectedTags,
              allAvailableTags: _allTags,
              onTagsChanged: (tags) {
                setState(() {
                  _selectedTags
                    ..clear()
                    ..addAll(tags);
                });
              },
            ),
            const SizedBox(height: 28),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.icon,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  elevation: 2,
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "save collage",
                  style: TextStyle(
                    fontFamily: 'Futura',
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1.1,
                  ),
                ),
                onPressed: _saveCollage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
