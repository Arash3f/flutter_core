import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';

class TBottomSheetTheme {
  const TBottomSheetTheme._();

  static BottomSheetThemeData lightBottomSheetTheme() => BottomSheetThemeData(
        backgroundColor: CustomColors.white,
        modalBackgroundColor: CustomColors.white,
        showDragHandle: true,
        shape: _shape,
        constraints: _constraints,
      );

  static BottomSheetThemeData darkBottomSheetTheme() => BottomSheetThemeData(
        backgroundColor: const Color(0xFF1E293B),
        modalBackgroundColor: const Color(0xFF1E293B),
        showDragHandle: true,
        shape: _shape,
        constraints: _constraints,
      );

  static final RoundedRectangleBorder _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(TSizes.cardRadiusLg),
    ),
  );

  static const BoxConstraints _constraints =
      BoxConstraints(minWidth: double.infinity);
}
