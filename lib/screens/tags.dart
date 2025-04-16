import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                !_selectedTags.contains(tag)
            );
          },
          onSelected: _addTag,
          fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
            _tagController.value = controller.value;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              decoration: const InputDecoration(
                labelText: "Добавить тег",
                suffixIcon: Icon(Icons.add),
              ),
              onSubmitted: (value) {
                _addTag(value);
                onEditingComplete();
              },
            );
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _selectedTags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () => _removeTag(tag),
              deleteIcon: const Icon(Icons.close),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text("Существующие теги:", style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableNotSelected.map((tag) {
            return ActionChip(
              label: Text(tag),
              onPressed: () => _addTag(tag),
              backgroundColor: Colors.grey[200],
              shape: StadiumBorder(),
            );
          }).toList(),
        ),
      ],
    );
  }
}
