import 'package:flutter/material.dart';
import '../app_colors.dart';

class DashboardTextStyles {
  static TextStyle title(BuildContext context) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText(context),
      );

  static TextStyle cardValue(BuildContext context) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.accentText(context),
      );

  static TextStyle cardLabel(BuildContext context) => TextStyle(
        fontSize: 14,
        color: AppColors.secondaryText(context),
      );
}

class DashboardIconStyles{
    static Color totalContractsIconColor(BuildContext context) => Colors.blue;

    static Color totalContractsValueIconColor(BuildContext context) => Colors.green;
}