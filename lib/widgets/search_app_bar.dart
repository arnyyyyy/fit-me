import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class SearchAppBar<TModel> extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String hintText;
  final TModel model;
  final TextEditingController controller;
  final void Function(String query) onSearchChanged;
  final void Function() onToggleSearch;
  final void Function() onToggleFilter;
  final void Function() onLoadTags;
  final void Function()? onAdd;

  const SearchAppBar({
    super.key,
    required this.title,
    required this.hintText,
    required this.model,
    required this.controller,
    required this.onSearchChanged,
    required this.onToggleSearch,
    required this.onToggleFilter,
    required this.onLoadTags,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isSearching = (model as dynamic).isSearching as bool;
    final isTagFilterVisible = (model as dynamic).isTagFilterVisible as bool;
    final searchQuery = (model as dynamic).searchQuery as String;

    controller.text = searchQuery;
    controller.selection = TextSelection.collapsed(offset: searchQuery.length);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: isSearching
          ? TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.body,
                border: InputBorder.none,
              ),
              style: AppTextStyles.imageTitle,
              onChanged: onSearchChanged,
            )
          : Text(title, style: AppTextStyles.appBarTitle),
      actions: [
        IconButton(
          icon: Icon(isSearching ? Icons.close : Icons.search),
          color: AppColors.icon,
          onPressed: onToggleSearch,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          color: AppColors.icon,
          onPressed: () {
            onToggleFilter();
            if (!isTagFilterVisible) {
              onLoadTags();
            }
          },
        ),
        if (onAdd != null)
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.icon,
            onPressed: onAdd,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
