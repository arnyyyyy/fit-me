import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  static const appBarTitle = TextStyle(
    color: AppColors.title,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: 'Courier',
  );

  static const emptyText = TextStyle(
    color: AppColors.emptyText,
    fontSize: 16,
    fontFamily: 'Courier',
  );

  static const imageTitle = TextStyle(
    fontFamily: 'Courier',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.icon,
  );

  static const tagText = TextStyle(
    fontSize: 10,
    fontFamily: 'Courier',
    color: AppColors.tagText,
  );
}
