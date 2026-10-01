import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// The two themes share one scale and differ only in color, so a size tweak
/// never has to be applied twice.
///
/// These are methods rather than `static final` fields on purpose: `.sp` reads
/// the current `ScreenUtil` configuration, and a field would freeze the first
/// value it ever computed even after a resize or orientation change.
class TTextTheme {
  const TTextTheme._();

  static TextTheme lightTextTheme() =>
      _build(primary: CustomColors.black, muted: CustomColors.greyDark);

  static TextTheme darkTextTheme() =>
      _build(primary: CustomColors.white, muted: CustomColors.greyLight);

  static TextTheme _build({required Color primary, required Color muted}) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      displayMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      displaySmall: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineLarge: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0.14,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.14,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.14,
      ),
      titleLarge: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0.24,
      ),
      titleMedium: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.24,
      ),
      titleSmall: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: muted,
        letterSpacing: 0.24,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: primary,
        letterSpacing: 0.14,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: primary,
        letterSpacing: 0.14,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: muted,
        letterSpacing: 0.14,
      ),
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: primary,
        letterSpacing: 0.16,
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: primary,
        letterSpacing: 0.16,
      ),
      labelSmall: TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w400,
        color: muted,
        letterSpacing: 0.16,
      ),
    );
  }
}
