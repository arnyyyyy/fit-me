import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../saved_image.dart';
import 'select_image_screen.dart';

class AllClothesScreen extends StatefulWidget {
  const AllClothesScreen({super.key});

  @override
  State<AllClothesScreen> createState() => _AllClothesScreenState();
}

class _AllClothesScreenState extends State<AllClothesScreen> {
  late Future<Box<SavedImage>> _imageBoxFuture;

  @override
  void initState() {
    super.initState();
    _imageBoxFuture = Hive.openBox<SavedImage>('imagesBox');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "my clothes",
          style: TextStyle(
            color: Color(0xFF4C1A1A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Color(0xFF5B1F1F),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add),
            color: Color(0xFF5B1F1F),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SelectImageScreen()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Box<SavedImage>>(
        future: _imageBoxFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final box = snapshot.data!;
          final images = box.values.toList();

          if (images.isEmpty) {
            return const Center(
              child: Text(
                "the closet is still empty...",
                style: TextStyle(
                  color: Color(0xFF7C3A3A),
                  fontSize: 16,
                  fontFamily: 'Courier',
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 20,
              childAspectRatio: 3 / 4.5,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final saved = images[index];
              final tags = saved.tags;
              final visibleTags = tags.take(2).toList();
              final hiddenCount = tags.length - visibleTags.length;

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF6),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.brown.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(3, 4),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFDFCFC1), width: 1),
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: Image.file(
                        File(saved.imagePath),
                        width: double.infinity,
                        height: 170,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              saved.name.toLowerCase(),
                              style: const TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(
                                    0xFF5B1F1F),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: -4,
                              children: [
                                for (var tag in visibleTags)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4DDD3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "#$tag",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Courier',
                                        color: Color(0xFF5B1F1F),
                                      ),
                                    ),
                                  ),
                                if (hiddenCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9B9B4),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "+$hiddenCount",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'Courier',
                                        color: Color(0xFF5B1F1F),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

