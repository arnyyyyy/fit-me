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

  static const TextStyle navLabelSelected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    letterSpacing: 0.5,
    fontFamily: 'Courier',
  );

  static const TextStyle navLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.tagText,
    letterSpacing: 0.5,
    fontFamily: 'Courier',
  );

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    fontFamily: 'Courier',

  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    fontFamily: 'Courier',

  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
    fontFamily: 'Courier',
    letterSpacing: 0.3,
  );

  static const TextStyle buttonWhite = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.3,
    fontFamily: 'Courier',

  );



  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.text,
    fontFamily: 'Courier',

  );

  static const TextStyle muted = TextStyle(
    fontSize: 14,
    color: AppColors.mutedText,
    fontFamily: 'Courier',
  );



}