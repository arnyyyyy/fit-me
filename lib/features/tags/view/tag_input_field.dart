import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';

class TagInputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onTagAdded;

  const TagInputField({
    super.key,
    required this.controller,
    required this.onTagAdded,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: 'Добавить тег...',
        hintStyle: AppTextStyles.body.copyWith(color: Colors.grey),
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add, color: AppColors.accent),
          onPressed: _addTag,
        ),
      ),
      onEditingComplete: _addTag,
      onSubmitted: (_) => _addTag(),
    );
  }

  void _addTag() {
    final text = controller.text.trim();
    if (text.isNotEmpty) {
      onTagAdded(text);
    }
  }
}
