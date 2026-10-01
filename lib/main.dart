import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/app.dart';
import 'package:flutter_core/core/utils/constants/enum.dart';
import 'package:flutter_core/core/utils/local_storage/helper_functions.dart';
import 'package:flutter_core/core/utils/local_storage/shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// Directory declared under `flutter/assets` in `pubspec.yaml`.
const String _translationsPath = 'assets/translations';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EasyLocalization.ensureInitialized();

  // Must complete before the first build: AppSettingsNotifier reads the stored
  // theme and language synchronously.
  await SharedPrefs.init();

  await _configureDesktopWindow();

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

/// Minimum size keeps the navigation rail layout from collapsing on desktop.
Future<void> _configureDesktopWindow() async {
  final isDesktop =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);
  if (!isDesktop) return;

  await windowManager.ensureInitialized();
  const options = WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(400, 640),
    center: true,
    title: 'Flutter Core',
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
