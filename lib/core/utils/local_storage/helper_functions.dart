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

  static Future<String?> getAccessToken() =>
      _secureStorage.read(key: SecureStorage.accessToken);

  static Future<String?> getRefreshToken() =>
      _secureStorage.read(key: SecureStorage.refreshToken);

  /// Writes the pair together so a crash between the two writes cannot leave
  /// a new access token next to a stale refresh token for long: the next
  /// refresh simply fails and the user logs in again.
  static Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    String tokenType = 'bearer',
  }) async {
    await _secureStorage.write(
      key: SecureStorage.accessToken,
      value: accessToken,
    );
    await _secureStorage.write(
      key: SecureStorage.refreshToken,
      value: refreshToken,
    );
    await _secureStorage.write(key: SecureStorage.tokenType, value: tokenType);
  }

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: SecureStorage.accessToken);
    await _secureStorage.delete(key: SecureStorage.refreshToken);
    await _secureStorage.delete(key: SecureStorage.tokenType);
  }
}
