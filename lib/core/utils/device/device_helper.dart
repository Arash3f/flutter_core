import 'dart:io';

import 'package:flutter/material.dart';

class Device {
  const Device._();

  /// The `sizeOf` / `platformBrightnessOf` accessors subscribe to one property
  /// instead of the whole `MediaQueryData`, so a keyboard opening does not
  /// rebuild every widget that only asked for the width.

  /// * Get Screen Width
  static double getScreenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  /// * Get Screen Height
  static double getScreenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  /// * Get Screen Percent Height
  static double getPercentScreenHeight(BuildContext context, double percent) =>
      (percent * getScreenHeight(context)) / 100;

  /// * Get Screen Percent Width
  static double getPercentScreenWidth(BuildContext context, double percent) =>
      (percent * getScreenWidth(context)) / 100;

  // * Get Bottom Navigation Bar Height
  static double getBottomNavigationBarHeight() => kBottomNavigationBarHeight;

  // * Get AppBar Height
  static double getAppBarHeight() => kToolbarHeight;

  /// * Height of the system status bar / notch area
  static double getStatusBarHeight(BuildContext context) =>
      MediaQuery.viewPaddingOf(context).top;

  /// * Height of the on-screen keyboard, 0 when it is closed
  static double getKeyboardHeight(BuildContext context) =>
      MediaQuery.viewInsetsOf(context).bottom;

  // * Check Device is IOS
  static bool isIOS() => Platform.isIOS;

  // * Check Device is Android
  static bool isAndroid() => Platform.isAndroid;

  /// * Whether the *system* is in dark mode.
  ///
  /// This is not the app's theme: the user may have picked
  /// `ThemeMode.light` explicitly. For that, read
  /// `Theme.of(context).brightness`.
  static bool isSystemDarkMode(BuildContext context) =>
      MediaQuery.platformBrightnessOf(context) == Brightness.dark;
}
