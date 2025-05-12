import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/tag_filter_bar.dart';
import '../../../widgets/search_app_bar.dart';
import '../../wardrobe/model/saved_image.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../message/clothes_picker_tag_messages.dart';
import '../model/clothes_picker_model.dart';
import '../effect/clothes_picker_runtime.dart';

export 'clothes_picker_screen.dart';

final searchControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class ClothesPickerScreen extends ConsumerStatefulWidget {
  final List<File> images;

  const ClothesPickerScreen({super.key, required this.images});

  @override
  ConsumerState<ClothesPickerScreen> createState() =>
      _ClothesPickerScreenState();
}

class _ClothesPickerScreenState extends ConsumerState<ClothesPickerScreen> {
  final Set<File> _selected = {};

  List<String> _availableTags = [];
  List<String> _selectedTags = [];
  List<File> _filteredImages = [];
  bool _isSearching = false;
  String _searchQuery = '';
  bool _isTagFilterVisible = false;

  List<String> get selectedTags => _selectedTags;

  void addTag(String tag) {
    setState(() {
      _selectedTags.add(tag);
    });
    _filterImages();
  }

  void removeTag(String tag) {
    setState(() {
      _selectedTags.remove(tag);
    });
    _filterImages();
  }

  void clearTags() {
    setState(() {
      _selectedTags.clear();
    });
    _filterImages();
  }

  void loadTags() {
    _loadTags();
  }

  void filterBySearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterImages();
  }

  void toggleSearch(bool isSearching) {
    setState(() {
      _isSearching = isSearching;
      if (!isSearching) {
        _searchQuery = '';
      }
    });
    _filterImages();
  }

  void toggleTagFilter(bool isVisible) {
    setState(() {
      _isTagFilterVisible = isVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredImages = widget.images;
    _loadTags();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _filterImages();
    });
  }

  Future<void> _loadTags() async {
    try {
      final box = await Hive.openBox<SavedImage>('imagesBox');
      final savedImages = box.values.toList();

      final Set<String> tagsSet = {};
      for (var img in savedImages) {
        tagsSet.addAll(img.tags);
      }

      setState(() {
        _availableTags = tagsSet.toList()..sort();
      });
    } catch (e) {
      debugPrint('Error loading tags: $e');
    }
  }

  void _filterImages() async {
    try {
      if (_selectedTags.isEmpty && _searchQuery.isEmpty) {
        setState(() {
          _filteredImages = widget.images;
        });
        return;
      }

      final box = await Hive.openBox<SavedImage>('imagesBox');
      final savedImages = box.values.toList();

      final Map<String, SavedImage> imagesMap = {};
      for (var img in savedImages) {
        imagesMap[img.imagePath] = img;
      }

      // Фильтруем изображения
      final filtered = widget.images.where((file) {
        final savedImage = imagesMap[file.path];
        if (savedImage == null) return false;

        // Проверка по тегам
        bool matchesTags = true;
        if (_selectedTags.isNotEmpty) {
          matchesTags =
              _selectedTags.every((tag) => savedImage.tags.contains(tag));
        }

        // Проверка по поисковому запросу
        bool matchesQuery = true;
        if (_searchQuery.isNotEmpty) {
          final lowercaseQuery = _searchQuery.toLowerCase();
          final nameMatch =
              savedImage.name.toLowerCase().contains(lowercaseQuery);
          final tagMatch = savedImage.tags
              .any((tag) => tag.toLowerCase().contains(lowercaseQuery));
          matchesQuery = nameMatch || tagMatch;
        }

        return matchesTags && matchesQuery;
      }).toList();

      setState(() {
        _filteredImages = filtered;
        debugPrint(
            "Фильтрация по тегам: ${_selectedTags.join(", ")} и поиску: '$_searchQuery'. Отобрано ${filtered.length} из ${widget.images.length} изображений");
      });
    } catch (e) {
      debugPrint('Error filtering images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(searchControllerProvider);
    final pickerModel = ClothesPickerModel(
      availableTags: _availableTags,
      selectedTags: _selectedTags,
      isSearching: _isSearching,
      searchQuery: _searchQuery,
      isTagFilterVisible: _isTagFilterVisible,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SearchAppBar(
        title: AppLocalizations.of(context).selectPhotos,
        hintText: AppLocalizations.of(context).searchNameOrTags,
        model: pickerModel,
        controller: controller,
        onSearchChanged: filterBySearchQuery,
        onToggleSearch: () => toggleSearch(!_isSearching),
        onToggleFilter: () => toggleTagFilter(!_isTagFilterVisible),
        onLoadTags: loadTags,
        onAdd: () => Navigator.pop(context, _selected.toList()),
      ),
      body: Column(
        children: [
          if (_isTagFilterVisible && _availableTags.isNotEmpty)
            _buildTagFilterBar(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: _filteredImages.length,
              itemBuilder: (context, index) {
                final file = _filteredImages[index];
                final isSelected = _selected.contains(file);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isSelected ? _selected.remove(file) : _selected.add(file);
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(file, fit: BoxFit.cover),
                      ),
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Icon(Icons.check_circle,
                                color: Colors.white, size: 36),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagFilterBar() {
    final pickerModel = ClothesPickerModel(
      availableTags: _availableTags,
      selectedTags: _selectedTags,
      isSearching: _isSearching,
      searchQuery: _searchQuery,
      isTagFilterVisible: _isTagFilterVisible,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: TagFilterBar<TagMessage>(
        modelProvider: StateProvider((ref) => pickerModel),
        runtimeBuilder: (ctx, ref) => ClothesPickerRuntime(ctx, ref, this),
        backgroundColor: AppColors.background,
        shadowColor: AppColors.shadow,
        tagSelectedMessage: (tag, isSelected) => TagSelected(tag, isSelected),
        clearFiltersMessage: ClearTagFilters(),
      ),
    );
  }
}
