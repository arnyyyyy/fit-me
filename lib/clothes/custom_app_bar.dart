import 'package:flutter/material.dart';

import '../screens/select_image_screen.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text("my clothes", style: AppTextStyles.appBarTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          color: AppColors.icon,
          onPressed: () {},
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

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
