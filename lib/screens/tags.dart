import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class TagSelectorWidget extends StatefulWidget {
  final List<String> initialTags;
  final List<String> allAvailableTags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagSelectorWidget({
    super.key,
    required this.initialTags,
    required this.allAvailableTags,
    required this.onTagsChanged,
  });

  @override
  State<TagSelectorWidget> createState() => _TagSelectorWidgetState();
}

class _TagSelectorWidgetState extends State<TagSelectorWidget> {
  late List<String> _selectedTags;
  final TextEditingController _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialTags);
  }

  void _addTag(String tag) {
    tag = tag.trim();
    if (tag.isEmpty || _selectedTags.contains(tag)) return;

    setState(() {
      _selectedTags.add(tag);
      _tagController.clear();
    });
    widget.onTagsChanged(_selectedTags);
  }

  void _removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    widget.onTagsChanged(_selectedTags);
  }

  @override
  Widget build(BuildContext context) {
    final availableNotSelected = widget.allAvailableTags
        .where((tag) => !_selectedTags.contains(tag))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            return widget.allAvailableTags.where((tag) =>
            tag.toLowerCase().contains(textEditingValue.text.toLowerCase()) &&
                !_selectedTags.contains(tag));
          },
          onSelected: _addTag,
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            _tagController.value = controller.value;
            return TextField(
              controller: controller,
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
                suffixIcon: Icon(Icons.add, color: AppColors.accent),
              ),
              onSubmitted: (value) {
                _addTag(value);
                onEditingComplete();
              },
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _selectedTags.map((tag) {
            return Chip(
              label: Text(tag, style: AppTextStyles.body.copyWith(color: Colors.white)),
              backgroundColor: AppColors.accent,
              deleteIconColor: Colors.white,
              onDeleted: () => _removeTag(tag),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          "Существующие теги:",
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableNotSelected.map((tag) {
            return ActionChip(
              label: Text(tag, style: AppTextStyles.body),
              backgroundColor: AppColors.surface,
              onPressed: () => _addTag(tag),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: AppColors.accent.withOpacity(0.2),
            );
          }).toList(),
        ),
      ],
    );
  }
}
