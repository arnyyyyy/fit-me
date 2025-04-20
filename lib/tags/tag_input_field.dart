import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class TagInputField extends StatelessWidget {
  final TextEditingController controller;
  final List<String> allTags;
  final List<String> selectedTags;
  final ValueChanged<String> onTagAdded;

  const TagInputField({
    super.key,
    required this.controller,
    required this.allTags,
    required this.selectedTags,
    required this.onTagAdded,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return allTags.where((tag) =>
            tag.toLowerCase().contains(textEditingValue.text.toLowerCase()) &&
            !selectedTags.contains(tag));
      },
      onSelected: onTagAdded,
      fieldViewBuilder:
          (context, fieldController, focusNode, onEditingComplete) {
        controller.value = fieldController.value;
        return TextField(
          controller: fieldController,
          focusNode: focusNode,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            labelText: "Добавить тег",
            labelStyle: AppTextStyles.body,
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: const Icon(Icons.add, color: AppColors.accent),
          ),
          onSubmitted: (value) {
            onTagAdded(value);
            onEditingComplete();
          },
        );
      },
    );
  }
}
