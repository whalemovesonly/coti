import 'package:flutter/material.dart';

class AppColors {
  static Color primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.grey;

  static Color inputText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;

  static Color buttonText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white;

  static Color icon(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white;

  static Color accentText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? Colors.cyanAccent : Colors.deepPurple;
}
