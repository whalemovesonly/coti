import 'package:flutter/material.dart';
import '../app_colors.dart';

class CreateContractTextStyles {
  static TextStyle formTitle(BuildContext context) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText(context),
      );

  static TextStyle label(BuildContext context) => TextStyle(
        fontSize: 14,
        color: AppColors.secondaryText(context),
      );

  static TextStyle inputText(BuildContext context) => TextStyle(
        fontSize: 16,
        color: AppColors.inputText(context),
      );
}

class CreateContractButtonStyles {
  static TextStyle selectDateButton(BuildContext context) => TextStyle(
        fontSize: 14,
        color: AppColors.primaryText(context),
      );
}
