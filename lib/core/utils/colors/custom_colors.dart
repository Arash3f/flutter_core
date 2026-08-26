import 'package:flutter/material.dart';

/// Brightness-independent brand palette.
///
/// Anything that changes between light and dark belongs in `DynamicColors`
/// instead, so a widget never has to branch on the theme itself.
class CustomColors {
  const CustomColors._();

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color secondary = Color(0xFF7C3AED);
  static const Color accent = Color(0xFF06B6D4);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0EA5E9);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE5E7EB);
  static const Color greyDark = Color(0xFF4B5563);
}
