import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TElevatedButtonTheme {
  const TElevatedButtonTheme._();

  static ElevatedButtonThemeData lightElevatedButtonTheme() =>
      _build(backgroundColor: CustomColors.primary);

  static ElevatedButtonThemeData darkElevatedButtonTheme() =>
      _build(backgroundColor: CustomColors.primaryDark);

  static ElevatedButtonThemeData _build({required Color backgroundColor}) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: CustomColors.white,
        disabledBackgroundColor: CustomColors.grey,
        disabledForegroundColor: CustomColors.greyLight,
        elevation: TSizes.buttonElevation,
        minimumSize: const Size(TSizes.buttonWidth, TSizes.buttonHeight),
        padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.buttonRadius),
        ),
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.20,
        ),
      ),
    );
  }
}
