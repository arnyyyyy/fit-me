import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/providers/hive_providers.dart';
import '../wardrobe/model/saved_image.dart';
import '../tags/tags.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class ImageMetaScreen extends ConsumerStatefulWidget {
  final Future<Uint8List> imageBytesFuture;

  const ImageMetaScreen({super.key, required this.imageBytesFuture});

  @override
  ConsumerState<ImageMetaScreen> createState() => _ImageMetaScreenState();
}

class _ImageMetaScreenState extends ConsumerState<ImageMetaScreen> {
  final TextEditingController _nameController = TextEditingController();
  List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          "Сохранить изображение",
          style: AppTextStyles.title,
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Uint8List>(
              future: widget.imageBytesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Ошибка загрузки изображения'));
                }

                if (snapshot.hasData) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(
                      snapshot.data!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: AppTextStyles.body,
              decoration: InputDecoration(
                labelText: "Название",
                labelStyle: AppTextStyles.body
                    .copyWith(color: AppColors.text.withValues(alpha: 0.6)),
                filled: true,
                fillColor: AppColors.inputBackground,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Теги", style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            tagsAsync.when(
              data: (allTags) => TagSelectorWidget(
                initialTags: _selectedTags,
                allAvailableTags: allTags,
                onTagsChanged: (tags) {
                  setState(() {
                    _selectedTags = tags;
                  });
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text("Не удалось загрузить теги"),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label:
                    const Text("Сохранить", style: AppTextStyles.buttonWhite),
                onPressed: _saveImage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveImage() async {
    final name = _nameController.text.trim();
    final tags = _selectedTags;

    if (name.isEmpty) return;

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$name.png';
    final file = File(filePath);
    await file.writeAsBytes(await widget.imageBytesFuture);

    final savedImage = SavedImage(name: name, imagePath: filePath, tags: tags);
    await ref.read(imageOperationsProvider).addImage(savedImage);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Изображение сохранено')),
      );
    }
  }
}
