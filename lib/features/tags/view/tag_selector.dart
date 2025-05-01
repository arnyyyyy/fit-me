import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../effect/runtime.dart';
import '../message/message.dart';
import 'available_tags_section.dart';
import 'selected_tags_chips.dart';
import 'tag_input_field.dart';

class TagSelector extends ConsumerStatefulWidget {
  final List<String> initialTags;
  final List<String> allAvailableTags;
  final ValueChanged<List<String>> onTagsChanged;

  const TagSelector({
    super.key,
    required this.initialTags,
    required this.allAvailableTags,
    required this.onTagsChanged,
  });

  @override
  ConsumerState<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends ConsumerState<TagSelector> {
  late final TextEditingController _tagController;
  late TagsRuntime _runtime;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tagController = TextEditingController();

    Future.microtask(() {
      if (!mounted) return;

      _runtime = TagsRuntime(context, ref, onTagsChanged: widget.onTagsChanged);
      _runtime.initWithTags(widget.initialTags, widget.allAvailableTags);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _tagController.dispose();
    if (_isInitialized) {
      _runtime.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(TagSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isInitialized &&
        oldWidget.allAvailableTags != widget.allAvailableTags) {
      _runtime.dispatch(TagsLoaded(widget.allAvailableTags));
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(tagsModelProvider);

    final runtime = _isInitialized
        ? _runtime
        : TagsRuntime(context, ref, onTagsChanged: widget.onTagsChanged);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TagInputField(
          controller: _tagController,
          onTagAdded: (tag) {
            runtime.dispatch(AddTag(tag));
            _tagController.clear();
          },
        ),
        const SizedBox(height: 12),
        SelectedTagsChips(
          selectedTags: model.selectedTags,
          onTagRemoved: (tag) => runtime.dispatch(RemoveTag(tag)),
        ),
        const SizedBox(height: 24),
        AvailableTagsSection(
          availableTags: model.availableTags
              .where((tag) => !model.selectedTags.contains(tag))
              .toList(),
          onTagSelected: (tag) => runtime.dispatch(AddTag(tag)),
        ),
      ],
    );
  }
}
