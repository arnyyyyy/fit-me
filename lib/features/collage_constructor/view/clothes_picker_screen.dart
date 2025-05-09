import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

class ClothesPickerScreen extends StatefulWidget {
  final List<File> images;

  const ClothesPickerScreen({super.key, required this.images});

  @override
  State<ClothesPickerScreen> createState() => _ClothesPickerScreenState();
}

class _ClothesPickerScreenState extends State<ClothesPickerScreen> {
  final Set<File> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).selectPhotos, style: AppTextStyles.appBarTitle),
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
