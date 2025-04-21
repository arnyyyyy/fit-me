import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filter_providers.dart';
import '../screens/select_image_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CustomAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  ConsumerState<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'name or tags',
                hintStyle: AppTextStyles.body,
                border: InputBorder.none,
              ),
              style: AppTextStyles.imageTitle,
              onChanged: (query) {
                ref.read(searchQueryProvider.notifier).state = query;
              },
            )
          : const Text("my clothes", style: AppTextStyles.appBarTitle),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          color: AppColors.icon,
          onPressed: () {
            setState(() {
              if (_isSearching) {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              }
              _isSearching = !_isSearching;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          color: AppColors.icon,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SelectImageScreen()),
            );
          },
        ),
      ],
    );
  }
}
