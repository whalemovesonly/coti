import 'package:flutter/material.dart';
import 'theme_type.dart';
import 'app_colors.dart'; // dark

final appThemes = {
  AppThemeType.light: ThemeData.light().copyWith(
    colorScheme: ColorScheme.light(
      primary: AppColorsLight.accent,
      secondary: AppColorsLight.accent,
      surface: AppColorsLight.surface,
      background: AppColorsLight.background,
      tertiary: AppColorsLight.warningText,
      surfaceVariant: AppColorsLight.warningBackground,
    ),
    primaryColor: AppColorsLight.accent,
    scaffoldBackgroundColor: AppColorsLight.background,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColorsLight.primaryText),
      bodyMedium: TextStyle(color: Colors.black87),
      titleLarge: TextStyle(
        color: AppColorsLight.accent,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(color: AppColorsLight.primaryText),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColorsLight.surface,
      foregroundColor: AppColorsLight.accent,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsLight.surface,
        foregroundColor: AppColorsLight.accent,
        side: const BorderSide(color: AppColorsLight.accent),
      ),
    ),
  ),
  AppThemeType.dark: ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      background: AppColors.background,
      tertiary: AppColors.warningText,
      surfaceVariant: AppColors.warningBackground,
    ),
    primaryColor: AppColors.accent,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primaryText),
      bodyMedium: TextStyle(color: AppColors.primaryText),
      titleLarge: TextStyle(
        color: AppColors.accent,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(color: AppColors.primaryText),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.accent,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.accent,
        side: const BorderSide(color: AppColors.accent),
      ),
    ),
  ),
};