import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/constants/enum.dart';
import 'package:flutter_core/core/utils/local_storage/secure_storage/secure_storage.dart';
import 'package:flutter_core/core/utils/local_storage/shared_preferences/shared_preferences.dart';

/// Typed accessors for the handful of values the app persists.
///
/// Keeping the raw keys in one place means a rename never leaves a stale
/// string literal behind in a widget.
class AppStorageHelper {
  const AppStorageHelper._();

  static const SecureStorage _secureStorage = SecureStorage();

  static LanguageList getActiveLanguage() =>
      LanguageList.fromCode(SharedPrefs.readData<String>(SharedPrefs.lang));

  static Future<void> setActiveLanguage(LanguageList language) async {
    await SharedPrefs.saveData(SharedPrefs.lang, language.code);
  }

  static ThemeMode getActiveTheme() {
    final stored = SharedPrefs.readData<String>(SharedPrefs.theme);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  static Future<void> setActiveTheme(ThemeMode themeMode) async {
    await SharedPrefs.saveData(SharedPrefs.theme, themeMode.name);
  }

  /// `true` only when dark mode was explicitly chosen. When the stored value is
  /// [ThemeMode.system] the answer depends on the platform, so ask the
  /// `BuildContext` instead of this helper.
  static bool isThemeDark() => getActiveTheme() == ThemeMode.dark;

  static Future<String?> getUserToken() =>
      _secureStorage.read(key: SecureStorage.token);

  static Future<void> setUserToken(String token) =>
      _secureStorage.write(key: SecureStorage.token, value: token);

  static Future<void> clearUserToken() =>
      _secureStorage.delete(key: SecureStorage.token);
}
