import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../features/tags/tags.dart';
import '../effect/runtime.dart';
import '../message/message.dart';

class CollageMetaScreen extends ConsumerStatefulWidget {
  final Uint8List collageBytes;

  const CollageMetaScreen({super.key, required this.collageBytes});

  @override
  ConsumerState<CollageMetaScreen> createState() => _CollageMetaScreenState();
}

class _CollageMetaScreenState extends ConsumerState<CollageMetaScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final runtime = CollagesRuntime(context, ref);
      runtime.dispatch(InitMetaScreen(widget.collageBytes));
      runtime.loadTags();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(collagesModelProvider);
    final runtime = CollagesRuntime(context, ref);

    return Scaffold(
      backgroundColor: AppColors.metaScreenBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).saveCollage,
            style: AppTextStyles.appBarTitle),
        iconTheme: const IconThemeData(color: AppColors.icon),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: AppColors.primary),
            onPressed: () {
              final name = _nameController.text.trim();
              if (name.isEmpty) return;

              runtime.saveCollageWithMetadata(
                  name, model.selectedTags, widget.collageBytes);
            },
          ),
          const SizedBox(width: 10)
        ],
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
              maxLength: 12,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).collageName,
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
              onChanged: (value) {
                runtime.dispatch(CollageNameChanged(value));
              },
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context).tags,
                style: AppTextStyles.imageTitle),
            const SizedBox(height: 8),
            model.isTagsLoading
                ? const Center(child: CircularProgressIndicator())
                : TagSelector(
                    initialTags: model.selectedTags,
                    allAvailableTags: model.availableTags,
                    onTagsChanged: (tags) {
                      runtime.dispatch(CollageTagsChanged(tags));
                    },
                  ),
            const SizedBox(height: 28),
            if (model.isProcessing)
              const Center(child: CircularProgressIndicator())
          ],
        ),
      ),
    );
  }
}
