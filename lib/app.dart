import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/providers/app_settings_provider.dart';
import 'package:flutter_core/core/router/app_router.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/utils/theme/theme.dart';
import 'package:flutter_core/core/widgets/splash_gate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Root widget. Rebuilds only when the persisted theme or language changes.
class App extends ConsumerWidget {
  const App({super.key});

  /// Reference device the `.sp` / `.w` / `.h` values were designed against.
  static const Size designSize = Size(390, 844);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      // The themes read `.sp`, so they have to be built inside this builder,
      // after ScreenUtil has been configured.
      builder: (context, _) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (_) => LocaleKeys.brand.tr(),
        themeMode: settings.themeMode,
        theme: TAppTheme.lightTheme(settings.language),
        darkTheme: TAppTheme.darkTheme(settings.language),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: router,
        // Above the router's Navigator, so the splash covers every route
        // while the session is being restored.
        builder: (context, routed) =>
            SplashGate(child: routed ?? const SizedBox.shrink()),
      ),
    );
  }
}
