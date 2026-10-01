import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';

class TAppBarTheme {
  const TAppBarTheme._();

  /// Same fill as [DynamicColorsName.background] / scaffold — avoids a white
  /// bar over a Paper body (or the reverse) when switching tabs.
  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    backgroundColor: CustomColors.paper,
    foregroundColor: CustomColors.ink,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: CustomColors.ink),
    actionsIconTheme: IconThemeData(color: CustomColors.ink),
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  );

  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    backgroundColor: CustomColors.ink,
    foregroundColor: CustomColors.paper,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: CustomColors.paper),
    actionsIconTheme: IconThemeData(color: CustomColors.paper),
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  );
}
