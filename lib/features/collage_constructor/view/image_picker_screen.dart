import 'dart:io';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

class ImagePickerScreen extends StatefulWidget {
  final List<File> images;

  const ImagePickerScreen({super.key, required this.images});

  @override
  State<ImagePickerScreen> createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  final Set<File> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("выберите фото", style: AppTextStyles.appBarTitle),
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
                      child: Icon(Icons.check_circle,
                          color: Colors.white, size: 36),
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
