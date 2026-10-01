import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/constants/enum.dart';
import 'package:flutter_core/core/utils/local_storage/helper_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppSettings extends Equatable {
  const AppSettings({required this.themeMode, required this.language});

  final ThemeMode themeMode;
  final LanguageList language;

  AppSettings copyWith({ThemeMode? themeMode, LanguageList? language}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
      );

  @override
  List<Object?> get props => [themeMode, language];
}

/// Reads the persisted preferences synchronously — `SharedPrefs.init()` is
/// awaited in `main` before the first build, so no loading state is needed.
class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => AppSettings(
    themeMode: AppStorageHelper.getActiveTheme(),
    language: AppStorageHelper.getActiveLanguage(),
  );

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (themeMode == state.themeMode) return;

    await AppStorageHelper.setActiveTheme(themeMode);
    if (!ref.mounted) return;
    // Preserve language explicitly: a rebuild mid-language-change must not
    // drop the other field if a future copyWith ever treats enums as nullable.
    state = state.copyWith(themeMode: themeMode, language: state.language);
  }

  Future<void> setLanguage(LanguageList language) async {
    if (language == state.language) return;

    await AppStorageHelper.setActiveLanguage(language);
    if (!ref.mounted) return;
    state = state.copyWith(language: language, themeMode: state.themeMode);
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);
