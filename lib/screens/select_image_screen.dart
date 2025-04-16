import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'image_editor_screen.dart';

class SelectImageScreen extends StatelessWidget {
  const SelectImageScreen({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final Uint8List bytes = await pickedFile.readAsBytes();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageEditorScreen(imageBytes: bytes),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => _pickImage(context),
          icon: const Icon(Icons.photo_library, color: Colors.white),
          label: const Text(
            'Открыть галерею',
            style: AppTextStyles.buttonWhite,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            shadowColor: AppColors.accent.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}
