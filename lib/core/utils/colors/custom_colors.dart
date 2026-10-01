import 'package:flutter/material.dart';

/// Brightness-independent brand palette (Arash Alfooneh — Ribbon A).
///
/// Tokens match [arash-alfooneh.ir](https://arash-alfooneh.ir) and the logo kit
/// under `assets/brand/`. Anything that flips between light and dark belongs
/// in `DynamicColors` instead.
class CustomColors {
  const CustomColors._();

  /// Signal Blue — primary accent and the mark on light surfaces.
  static const Color primary = Color(0xFF016DF1);

  /// Slightly deeper Signal Blue for pressed states and dark splash fallbacks.
  static const Color primaryDark = Color(0xFF0158C7);

  /// Soft tint of [primary] for selected chips and navigation indicators.
  static const Color primaryMuted = Color(0xFFD6E8FE);

  /// Bright Blue — highlights and links.
  static const Color secondary = Color(0xFF2F8BFF);

  /// Kept as a tertiary accent for charts / secondary CTAs.
  static const Color accent = Color(0xFF2F8BFF);

  /// Ink — dark background; primary form of the mark sits on this.
  static const Color ink = Color(0xFF08090D);

  /// Paper — light background.
  static const Color paper = Color(0xFFF5F7FA);

  /// Line — borders on dark surfaces.
  static const Color line = Color(0xFF111C2D);

  /// Muted — secondary text on dark.
  static const Color muted = Color(0xFF9AA4B2);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF2F8BFF);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE5E7EB);
  static const Color greyDark = Color(0xFF4B5563);
}
