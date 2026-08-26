import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_core/core/utils/colors/dynamic_colors.dart';
import 'package:flutter_core/core/utils/constants/enum.dart';
import 'package:flutter_core/core/utils/gen/fonts.gen.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/app_bar_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/check_box_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/chip_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/text_field_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/text_theme.dart';

class TAppTheme {
  const TAppTheme._();

  static ThemeData lightTheme(LanguageList language) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: _fontFamilyOf(language),
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.primary,
          brightness: Brightness.light,
          error: CustomColors.error,
        ),
        scaffoldBackgroundColor: DynamicColors.get(
          DynamicColorsName.background,
          brightness: Brightness.light,
        ),
        textTheme: TTextTheme.lightTextTheme(),
        appBarTheme: TAppBarTheme.lightAppBarTheme,
        chipTheme: TChipTheme.lightChipTheme(),
        checkboxTheme: TCheckBoxTheme.lightCheckboxTheme(),
        bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme(),
        inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme(),
        elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme(),
      );

  static ThemeData darkTheme(LanguageList language) => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: _fontFamilyOf(language),
        colorScheme: ColorScheme.fromSeed(
          seedColor: CustomColors.primary,
          brightness: Brightness.dark,
          error: CustomColors.error,
        ),
        scaffoldBackgroundColor: DynamicColors.get(
          DynamicColorsName.background,
          brightness: Brightness.dark,
        ),
        textTheme: TTextTheme.darkTextTheme(),
        appBarTheme: TAppBarTheme.darkAppBarTheme,
        chipTheme: TChipTheme.darkChipTheme(),
        checkboxTheme: TCheckBoxTheme.darkCheckboxTheme(),
        bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme(),
        inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme(),
        elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme(),
      );

  static String _fontFamilyOf(LanguageList language) =>
      language == LanguageList.persian
          ? FontFamily.iranSans
          : FontFamily.openSans;
}
