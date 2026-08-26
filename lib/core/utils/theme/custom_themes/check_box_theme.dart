import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';

class TCheckBoxTheme {
  const TCheckBoxTheme._();

  static CheckboxThemeData lightCheckboxTheme() => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? CustomColors.primary
              : Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(CustomColors.white),
        side: const BorderSide(color: CustomColors.greyDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
        ),
      );

  static CheckboxThemeData darkCheckboxTheme() => CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? CustomColors.primary
              : Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(CustomColors.white),
        side: const BorderSide(color: CustomColors.greyLight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TSizes.borderRadiusSm),
        ),
      );
}
