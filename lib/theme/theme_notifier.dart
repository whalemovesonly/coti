import 'package:flutter/material.dart';
import 'theme_type.dart';
import 'themes.dart';

class ThemeNotifier extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.dark;

  AppThemeType get currentTheme => _currentTheme;
  ThemeData get themeData => appThemes[_currentTheme]!;

  void switchTheme(AppThemeType newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
  }

  void toggleTheme() {
    _currentTheme = _currentTheme == AppThemeType.light
        ? AppThemeType.dark
        : AppThemeType.light;
    notifyListeners();
  }
}