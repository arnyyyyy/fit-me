import 'dart:io';

import 'package:fit_me/features/collages/model/saved_collage.dart';
import 'package:fit_me/features/edit_collage/effect/runtime.dart';
import 'package:fit_me/features/edit_collage/message/message.dart';
import 'package:fit_me/features/edit_collage/model/model.dart';
import 'package:fit_me/features/edit_collage/update/update.dart';
import 'package:fit_me/features/tags/view/tag_chip.dart';
import 'package:fit_me/features/tags/view/tag_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditCollageScreen extends StatefulWidget {
  final SavedCollage item;

  const EditCollageScreen({
    Key? key,
    required this.item,
  }) : super(key: key);

  static Route<bool> route(SavedCollage item) {
    return MaterialPageRoute<bool>(
      builder: (context) => EditCollageScreen(item: item),
    );
  }

  @override
  State<EditCollageScreen> createState() => _EditCollageScreenState();
}

class _EditCollageScreenState extends State<EditCollageScreen> {
  late EditCollageModel _model;
  late EditCollageRuntime _runtime;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = EditCollageModel(originalItem: widget.item);
    _nameController.text = _model.name;
    _runtime = EditCollageRuntime(
      context: context,
      onMessage: _handleMessage,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleMessage(EditCollageMessage message) {
    final result = update(_model, message);
    setState(() {
      _model = result.$1;
    });

    final effect = result.$2;
    if (effect != null) {
      _runtime.runEffect(effect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.editCollage),
        actions: [
          IconButton(
            onPressed: _model.isSaving || !_model.hasChanges || !_model.isValid
                ? null
                : () => _handleMessage(EditCollageSave()),
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _model.isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(File(_model.originalItem.imagePath)),
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Название
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: localizations.collageNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) => _handleMessage(EditCollageUpdateName(value)),
                  ),
                  const SizedBox(height: 16),
                  
                  // Теги
                  Text(
                    localizations.tagsLabel,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _model.tags.map((tag) {
                      return TagChip(
                        label: tag,
                        onDeleted: () => _handleMessage(EditCollageRemoveTag(tag)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  TagInputField(
                    onTagAdded: (tag) => _handleMessage(EditCollageAddTag(tag)),
                  ),
                ],
              ),
            ),
    );
  }
}