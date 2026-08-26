import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';

enum DynamicColorsName { background, surface, text, textMuted, border }

/// Colors that differ between light and dark mode.
///
/// The brightness comes from the widget tree rather than from storage, so the
/// value stays correct when the theme is [ThemeMode.system] or when the user
/// flips the system theme while the app is running.
class DynamicColors {
  const DynamicColors._();

  static Color of(BuildContext context, DynamicColorsName colorName) =>
      get(colorName, brightness: Theme.of(context).brightness);

  static Color get(
    DynamicColorsName colorName, {
    required Brightness brightness,
  }) {
    final pair = _dynamicColors[colorName]!;
    return brightness == Brightness.dark ? pair.dark : pair.light;
  }

  // Config all project's dynamic color here ...
  static const Map<DynamicColorsName, _ColorPair> _dynamicColors = {
    DynamicColorsName.background: _ColorPair(
      light: Color(0xFFFFFFFF),
      dark: Color(0xFF0F172A),
    ),
    DynamicColorsName.surface: _ColorPair(
      light: Color(0xFFF3F4F6),
      dark: Color(0xFF1E293B),
    ),
    DynamicColorsName.text: _ColorPair(
      light: CustomColors.black,
      dark: CustomColors.white,
    ),
    DynamicColorsName.textMuted: _ColorPair(
      light: CustomColors.greyDark,
      dark: CustomColors.greyLight,
    ),
    DynamicColorsName.border: _ColorPair(
      light: CustomColors.greyLight,
      dark: CustomColors.greyDark,
    ),
  };
}

class _ColorPair {
  const _ColorPair({required this.light, required this.dark});

  final Color light;
  final Color dark;
}
