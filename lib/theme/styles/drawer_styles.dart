import 'package:flutter/material.dart';
import '../app_colors.dart';

class DrawerTextStyles {
  static TextStyle header(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText(context),
      );

  static TextStyle menuItem(BuildContext context) => TextStyle(
        fontSize: 16,
        color: AppColors.secondaryText(context),
      );
}
