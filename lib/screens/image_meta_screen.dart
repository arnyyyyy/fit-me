import 'dart:typed_data';
import 'dart:io';

import 'package:fit_me/screens/tags.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../saved_image.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

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
      _allTags = tagsSet.toList()
        ..sort();
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          "Сохранить изображение",
          style: AppTextStyles.title,
        ),
        iconTheme: IconThemeData(color: AppColors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.memory(
                widget.imageBytes,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: "Название",
                labelStyle: AppTextStyles.body.copyWith(
                    color: AppColors.text.withOpacity(0.6)),
                filled: true,
                fillColor: AppColors.inputBackground,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            Text("Теги", style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            TagSelectorWidget(
              initialTags: _selectedTags,
              allAvailableTags: _allTags,
              onTagsChanged: (tags) {
                setState(() {
                  _selectedTags = tags;
                });
              },
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.save, color: Colors.white,),
                label: Text("Сохранить", style: AppTextStyles.buttonWhite),
                onPressed: _saveImage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
