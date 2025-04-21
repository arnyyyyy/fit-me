import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/hive_providers.dart';
import '../tags/tags.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CollageMetaScreen extends ConsumerStatefulWidget {
  final Uint8List collageBytes;

  const CollageMetaScreen({super.key, required this.collageBytes});

  @override
  ConsumerState<CollageMetaScreen> createState() => _CollageMetaScreenState();
}

class _CollageMetaScreenState extends ConsumerState<CollageMetaScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<String> _selectedTags = [];

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      backgroundColor: AppColors.metaScreenBackground,
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
            const Text("tags", style: AppTextStyles.imageTitle),
            const SizedBox(height: 8),
            tagsAsync.when(
              data: (allTags) => TagSelectorWidget(
                initialTags: _selectedTags,
                allAvailableTags: allTags,
                onTagsChanged: (tags) {
                  setState(() {
                    _selectedTags
                      ..clear()
                      ..addAll(tags);
                  });
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text("Failed to load tags"),
            ),
            const SizedBox(height: 28),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.icon,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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

  Future<void> _saveCollage() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    await ref.read(collageOperationsProvider).saveCollage(
        name: name, collageBytes: widget.collageBytes, tags: _selectedTags);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('collage is saved')),
      );
    }
  }
}
