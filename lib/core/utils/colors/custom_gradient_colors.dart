import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';

class CustomGradientColors {
  const CustomGradientColors._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [CustomColors.primary, CustomColors.secondary],
  );

  static const LinearGradient accent = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [CustomColors.accent, CustomColors.primary],
  );

  /// Top-to-bottom fade used behind text that sits on top of an image.
  static const LinearGradient scrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black54],
  );
}
