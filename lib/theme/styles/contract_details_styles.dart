import 'package:flutter/material.dart';
import '../app_colors.dart';

class ContractDetailsTextStyles {
  static TextStyle sectionTitle(BuildContext context) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText(context),
      );

  static TextStyle fieldLabel(BuildContext context) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.secondaryText(context),
      );

  static TextStyle fieldValue(BuildContext context) => TextStyle(
        fontSize: 16,
        color: AppColors.primaryText(context),
      );
}