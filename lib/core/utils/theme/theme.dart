import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_core/core/utils/colors/dynamic_colors.dart';
import 'package:flutter_core/core/utils/constants/enum.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_core/core/utils/gen/fonts.gen.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/app_bar_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/check_box_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/chip_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/text_field_theme.dart';
import 'package:flutter_core/core/utils/theme/custom_themes/text_theme.dart';

/// Light and dark [ThemeData].
///
/// The per-widget themes that differ by brightness live in `custom_themes/`.
/// Component themes that only need the [ColorScheme] (buttons, navigation,
/// dialogs, cards, ...) are derived once in [_build], so both modes stay in
/// sync by construction.
class TAppTheme {
  const TAppTheme._();

  static ThemeData lightTheme(LanguageList language) => _build(
    language: language,
    brightness: Brightness.light,
    textTheme: TTextTheme.lightTextTheme(),
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    chipTheme: TChipTheme.lightChipTheme(),
    checkboxTheme: TCheckBoxTheme.lightCheckboxTheme(),
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme(),
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme(),
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme(),
  );

  static ThemeData darkTheme(LanguageList language) => _build(
    language: language,
    brightness: Brightness.dark,
    textTheme: TTextTheme.darkTextTheme(),
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    chipTheme: TChipTheme.darkChipTheme(),
    checkboxTheme: TCheckBoxTheme.darkCheckboxTheme(),
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme(),
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme(),
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme(),
  );

  static ThemeData _build({
    required LanguageList language,
    required Brightness brightness,
    required TextTheme textTheme,
    required AppBarTheme appBarTheme,
    required ChipThemeData chipTheme,
    required CheckboxThemeData checkboxTheme,
    required BottomSheetThemeData bottomSheetTheme,
    required InputDecorationTheme inputDecorationTheme,
    required ElevatedButtonThemeData elevatedButtonTheme,
  }) {
    Color dynamic(DynamicColorsName name) =>
        DynamicColors.get(name, brightness: brightness);

    final background = dynamic(DynamicColorsName.background);
    final card = dynamic(DynamicColorsName.surfaceRaised);
    final divider = dynamic(DynamicColorsName.border);
    final selection = dynamic(DynamicColorsName.selection);
    // Keep ColorScheme.surface in sync with scaffoldBackgroundColor. A mismatch
    // flashes white (or a different shade) on every route change because page
    // transitions paint with `surface` before the scaffold color settles.
    final scheme = ColorScheme.fromSeed(
      seedColor: CustomColors.primary,
      brightness: brightness,
      error: CustomColors.error,
      surface: background,
    );
    final radius = BorderRadius.circular(TSizes.buttonRadius);
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: _fontFamilyOf(language),
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: appBarTheme,
      chipTheme: chipTheme,
      checkboxTheme: checkboxTheme,
      bottomSheetTheme: bottomSheetTheme,
      inputDecorationTheme: inputDecorationTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          minimumSize: const Size(64, TSizes.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(
            fontSize: TSizes.fontSizeMd,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: card,
        shape: cardShape,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        margin: EdgeInsets.zero,
        shape: cardShape.copyWith(side: BorderSide(color: divider)),
      ),
      dividerTheme: DividerThemeData(color: divider, space: 1, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: card,
        indicatorColor: selection,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: background,
        indicatorColor: selection,
        selectedIconTheme: IconThemeData(color: scheme.primary),
        selectedLabelTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  static String _fontFamilyOf(LanguageList language) =>
      language == LanguageList.persian
      ? FontFamily.iranSans
      : FontFamily.openSans;
}
