import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../saved_image.dart';

class AllClothesScreen extends StatelessWidget {
  const AllClothesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Мои изображения")),
      body: FutureBuilder<Box<SavedImage>>(
        future: Hive.openBox<SavedImage>('imagesBox'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final box = snapshot.data!;
          final images = box.values.toList();

          if (images.isEmpty) {
            return const Center(child: Text("Нет сохранённых изображений"));
          }

          return ListView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              final saved = images[index];
              return Card(
                margin: const EdgeInsets.all(8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(saved.imagePath),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(saved.name),
                  subtitle: Text(saved.tags.join(', ')),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await saved.delete();
                      (context as Element).reassemble();
                    },
                  ),
                  onTap: () {
                    //TODO
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
