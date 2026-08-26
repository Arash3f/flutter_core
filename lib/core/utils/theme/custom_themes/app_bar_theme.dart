import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';

class TAppBarTheme {
  const TAppBarTheme._();

  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    backgroundColor: CustomColors.white,
    foregroundColor: CustomColors.black,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: CustomColors.black),
    actionsIconTheme: IconThemeData(color: CustomColors.black),
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  );

  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    backgroundColor: Color(0xFF0F172A),
    foregroundColor: CustomColors.white,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: CustomColors.white),
    actionsIconTheme: IconThemeData(color: CustomColors.white),
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
  );
}
