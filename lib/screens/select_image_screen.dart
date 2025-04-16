import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      appBar: AppBar(title: const Text('Выберите изображение')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pickImage(context),
          child: const Text('Открыть галерею'),
        ),
      ),
    );
  }
}

