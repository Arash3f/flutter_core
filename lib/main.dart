import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/app.dart';
import 'package:flutter_core/core/utils/constants/enum.dart';
import 'package:flutter_core/core/utils/local_storage/helper_functions.dart';
import 'package:flutter_core/core/utils/local_storage/shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Directory declared under `flutter/assets` in `pubspec.yaml`.
const String _translationsPath = 'assets/translations';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();

  // Must complete before the first build: AppSettingsNotifier reads the stored
  // theme and language synchronously.
  await SharedPrefs.init();

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: LanguageList.supportedLocales,
        path: _translationsPath,
        fallbackLocale: LanguageList.persian.locale,
        startLocale: AppStorageHelper.getActiveLanguage().locale,
        child: const App(),
      ),
    ),
  );
}
