import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';

enum DynamicColorsName {
  background,
  surface,

  /// Cards, dialogs and sheets that sit above [surface].
  surfaceRaised,
  text,
  textMuted,
  border,

  /// Navigation indicator / selected-chip fill.
  selection,
}

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

  static const Map<DynamicColorsName, _ColorPair> _dynamicColors = {
    DynamicColorsName.background: _ColorPair(
      light: CustomColors.paper,
      dark: CustomColors.ink,
    ),
    DynamicColorsName.surface: _ColorPair(
      light: CustomColors.white,
      dark: CustomColors.line,
    ),
    DynamicColorsName.text: _ColorPair(
      light: CustomColors.ink,
      dark: CustomColors.paper,
    ),
    DynamicColorsName.textMuted: _ColorPair(
      light: CustomColors.greyDark,
      dark: CustomColors.muted,
    ),
    DynamicColorsName.border: _ColorPair(
      light: CustomColors.greyLight,
      dark: Color(0xFF1C2738),
    ),
    DynamicColorsName.surfaceRaised: _ColorPair(
      light: CustomColors.white,
      dark: Color(0xFF151B28),
    ),
    DynamicColorsName.selection: _ColorPair(
      light: CustomColors.primaryMuted,
      dark: Color(0xFF0A2A5C),
    ),
  };
}

class _ColorPair {
  const _ColorPair({required this.light, required this.dark});

  final Color light;
  final Color dark;
}
