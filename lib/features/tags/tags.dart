import 'package:fit_me/features/tags/selected_tags_chips.dart';
import 'package:fit_me/features/tags/tag_input_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'available_tags_selector.dart';

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
        TagInputField(
          controller: _tagController,
          allTags: widget.allAvailableTags,
          selectedTags: _selectedTags,
          onTagAdded: _addTag,
        ),
        const SizedBox(height: 12),
        SelectedTagsChips(
          selectedTags: _selectedTags,
          onTagRemoved: _removeTag,
        ),
        const SizedBox(height: 24),
        AvailableTagsSection(
          tags: availableNotSelected,
          onTagSelected: _addTag,
        ),
      ],
    );
  }
}
