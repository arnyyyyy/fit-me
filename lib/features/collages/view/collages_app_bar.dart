import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_text_styles.dart';
import '../message/message.dart';
import '../effect/runtime.dart';

final searchControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class CollagesAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  const CollagesAppBar({super.key});

  @override
  ConsumerState<CollagesAppBar> createState() => _CollagesAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CollagesAppBarState extends ConsumerState<CollagesAppBar> {
  bool _isListeningToModel = false;

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(collagesModelProvider);
    final runtime = Runtime(context, ref);
    final controller = ref.watch(searchControllerProvider);

    if (!_isListeningToModel) {
      _isListeningToModel = true;
      controller.text = model.searchQuery;
      controller.selection =
          TextSelection.collapsed(offset: model.searchQuery.length);
    }

    if (!model.isSearching) {
      _isListeningToModel = false;
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: model.isSearching
          ? TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'name or tags',
                hintStyle: AppTextStyles.body,
                border: InputBorder.none,
              ),
              style: AppTextStyles.imageTitle,
              onChanged: (query) {
                runtime.dispatch(SearchQueryChanged(query));
              },
            )
          : const Text("my collages", style: AppTextStyles.appBarTitle),
      actions: [
        IconButton(
          icon: Icon(model.isSearching ? Icons.close : Icons.search),
          color: AppColors.icon,
          onPressed: () {
            runtime.dispatch(ToggleSearch(!model.isSearching));
          },
        ),
        IconButton(
          icon: Icon(Icons.filter_list),
          color: AppColors.icon,
          onPressed: () {
            runtime.dispatch(ToggleTagFilter(!model.isTagFilterVisible));
            if (!model.isTagFilterVisible) {
              runtime.dispatch(LoadAvailableTags());
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          color: AppColors.icon,
          onPressed: () {
            runtime.dispatch(NavigateToCreateCollage());
          },
        ),
      ],
    );
  }
}
