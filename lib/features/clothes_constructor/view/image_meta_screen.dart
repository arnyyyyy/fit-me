import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../../../features/tags/tags.dart';
import '../effect/runtime.dart';
import '../message/message.dart';

class ImageMetaScreen extends ConsumerStatefulWidget {
  final Uint8List imageBytes;

  const ImageMetaScreen({super.key, required this.imageBytes});

  @override
  ConsumerState<ImageMetaScreen> createState() => _ImageMetaScreenState();
}

class _ImageMetaScreenState extends ConsumerState<ImageMetaScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final runtime = ImageConstructorRuntime(context, ref);
      runtime.dispatch(InitMetaScreen(widget.imageBytes));
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
    final model = ref.watch(imageConstructorModelProvider);
    final runtime = ImageConstructorRuntime(context, ref);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          AppLocalizations.of(context).saveImage,
          style: AppTextStyles.title,
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          IconButton(
              icon: const Icon(Icons.save, color: AppColors.primary),
              onPressed: model.isSaving
                  ? null
                  : () {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) return;

                      runtime.saveImageWithMeta(
                        name,
                        model.selectedTags,
                        widget.imageBytes,
                      );
                    }),
          const SizedBox(width: 10)
        ],
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
              maxLength: 12,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).name,
                labelStyle: AppTextStyles.body
                    .copyWith(color: AppColors.text.withValues(alpha: 0.6)),
                filled: true,
                fillColor: AppColors.inputBackground,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                runtime.dispatch(ChangeImageName(value));
              },
            ),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context).tags,
                style: AppTextStyles.subtitle),
            const SizedBox(height: 8),
            model.isTagsLoading
                ? const Center(child: CircularProgressIndicator())
                : TagSelector(
                    initialTags: model.selectedTags,
                    allAvailableTags: model.availableTags,
                    onTagsChanged: (tags) {
                      runtime.dispatch(ChangeSelectedTags(tags));
                    },
                  ),
            const SizedBox(height: 30),
            // Center(
            //   child: ElevatedButton.icon(
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primary,
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            //       shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(16)),
            //     ),
            //     icon: const Icon(Icons.save, color: Colors.white),
            //     label:
            //         Text(AppLocalizations.of(context).saveButton, style: AppTextStyles.buttonWhite),
            //     onPressed: model.isSaving
            //         ? null
            //         : () {
            //             final name = _nameController.text.trim();
            //             if (name.isEmpty) return;
            //
            //             runtime.saveImageWithMeta(
            //               name,
            //               model.selectedTags,
            //               widget.imageBytes,
            //             );
            //           },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
