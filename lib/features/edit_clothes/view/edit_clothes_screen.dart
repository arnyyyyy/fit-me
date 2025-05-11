import 'dart:io';

import 'package:fit_me/features/edit_clothes/effect/runtime.dart';
import 'package:fit_me/features/edit_clothes/message/message.dart';
import 'package:fit_me/features/edit_clothes/model/model.dart';
import 'package:fit_me/features/edit_clothes/update/update.dart';
import 'package:fit_me/features/tags/view/tag_chip.dart';
import 'package:fit_me/features/tags/view/tag_input_field.dart';
import 'package:fit_me/features/wardrobe/model/saved_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditClothesScreen extends StatefulWidget {
  final SavedImage item;

  const EditClothesScreen({
    super.key,
    required this.item,
  });

  static Route<bool> route(SavedImage item) {
    return MaterialPageRoute<bool>(
      builder: (context) => EditClothesScreen(item: item),
    );
  }

  @override
  State<EditClothesScreen> createState() => _EditClothesScreenState();
}

class _EditClothesScreenState extends State<EditClothesScreen> {
  late EditClothesModel _model;
  late EditClothesRuntime _runtime;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = EditClothesModel(originalItem: widget.item);
    _nameController.text = _model.name;
    _runtime = EditClothesRuntime(
      context: context,
      onMessage: _handleMessage,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleMessage(EditClothesMessage message) {
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
        title: Text(localizations.editItem),
        actions: [
          IconButton(
            onPressed: _model.isSaving || !_model.hasChanges || !_model.isValid
                ? null
                : () => _handleMessage(EditClothesSave()),
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
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(File(_model.originalItem.imagePath)),
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: localizations.itemNameLabel,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        _handleMessage(EditClothesUpdateName(value)),
                  ),
                  const SizedBox(height: 16),
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
                        onDeleted: () =>
                            _handleMessage(EditClothesRemoveTag(tag)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  TagInputField(
                    onTagAdded: (tag) => _handleMessage(EditClothesAddTag(tag)),
                  ),
                ],
              ),
            ),
    );
  }
}
