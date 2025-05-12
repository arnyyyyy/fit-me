import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/app_colors.dart';
import '../../../widgets/tag_filter_bar.dart';
import '../effect/runtime.dart';
import '../message/message.dart';

class TgFilterBar extends ConsumerWidget {
  const TgFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TagFilterBar<CollagesMessage>(
      modelProvider: collagesModelProvider,
      runtimeBuilder: (ctx, ref) => CollagesRuntime(ctx, ref),
      backgroundColor: AppColors.background,
      shadowColor: AppColors.shadow,
      tagSelectedMessage: (tag, isSelected) => TagSelected(tag, isSelected),
      clearFiltersMessage: ClearTagFilters(),
    );
  }
}
