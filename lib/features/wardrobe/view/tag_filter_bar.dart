import 'package:fit_me/features/wardrobe/effect/runtime.dart';
import 'package:fit_me/features/wardrobe/message/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/tag_filter_bar.dart';

class TgFilterBar extends ConsumerWidget {
  const TgFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TagFilterBar<Message>(
      modelProvider: modelProvider,
      runtimeBuilder: (ctx, ref) => Runtime(ctx, ref),
      backgroundColor: AppColors.wardrobeBackground,
      shadowColor: AppColors.shadow,
      tagSelectedMessage: (tag, isSelected) => TagSelected(tag, isSelected),
      clearFiltersMessage: ClearTagFilters(),
    );
  }
}
