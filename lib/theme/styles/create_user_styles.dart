import 'package:flutter/material.dart';
import '../app_colors.dart';

class CreateUserTextStyles {
  static TextStyle title(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText(context),
      );

  static TextStyle label(BuildContext context) => TextStyle(
        fontSize: 14,
        color: AppColors.secondaryText(context),
      );

  static TextStyle input(BuildContext context) => TextStyle(
        fontSize: 16,
        color: AppColors.inputText(context),
      );

  static TextStyle button(BuildContext context) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.buttonText(context),
      );
}
