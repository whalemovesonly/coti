import 'package:flutter/material.dart';
import '../app_colors.dart';

class LoginTextStyles {
  static TextStyle title(BuildContext context) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText(context),
      );

  static TextStyle subtitle(BuildContext context) => TextStyle(
        fontSize: 16,
        color: AppColors.secondaryText(context),
      );

  static TextStyle buttonText(BuildContext context) => TextStyle(
        fontSize: 16,
        color: AppColors.buttonText(context),
        fontWeight: FontWeight.w600,
      );
}

class LoginIconStyles{
    static Color iconColor(BuildContext context) => AppColors.icon(context);

}