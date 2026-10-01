import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TTextFormFieldTheme {
  const TTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme() => _build(
    fillColor: const Color(0xFFF3F4F6),
    labelColor: CustomColors.greyDark,
    borderColor: CustomColors.greyLight,
  );

  static InputDecorationTheme darkInputDecorationTheme() => _build(
    fillColor: const Color(0xFF1E293B),
    labelColor: CustomColors.greyLight,
    borderColor: CustomColors.greyDark,
  );

  static InputDecorationTheme _build({
    required Color fillColor,
    required Color labelColor,
    required Color borderColor,
  }) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(TSizes.inputFieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(
        vertical: TSizes.md,
        horizontal: TSizes.lg,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.never,
      filled: true,
      fillColor: fillColor,
      labelStyle: TextStyle(
        fontSize: 14.sp,
        color: labelColor,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.16,
      ),
      hintStyle: TextStyle(fontSize: 14.sp, color: labelColor),
      errorStyle: TextStyle(fontSize: 12.sp, color: CustomColors.error),
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(CustomColors.primary, width: 1.5),
      errorBorder: border(CustomColors.error),
      focusedErrorBorder: border(CustomColors.error, width: 1.5),
    );
  }
}
