import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';

class TChipTheme {
  const TChipTheme._();

  static ChipThemeData lightChipTheme() => ChipThemeData(
    backgroundColor: CustomColors.greyLight,
    disabledColor: CustomColors.greyLight.withValues(alpha: 0.4),
    selectedColor: CustomColors.primary,
    checkmarkColor: CustomColors.white,
    labelStyle: const TextStyle(color: CustomColors.black),
    padding: const EdgeInsets.symmetric(
      horizontal: TSizes.sm,
      vertical: TSizes.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
    ),
  );

  static ChipThemeData darkChipTheme() => ChipThemeData(
    backgroundColor: CustomColors.greyDark,
    disabledColor: CustomColors.greyDark.withValues(alpha: 0.4),
    selectedColor: CustomColors.primary,
    checkmarkColor: CustomColors.white,
    labelStyle: const TextStyle(color: CustomColors.white),
    padding: const EdgeInsets.symmetric(
      horizontal: TSizes.sm,
      vertical: TSizes.xs,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
    ),
  );
}
