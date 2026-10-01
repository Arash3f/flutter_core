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

    // Keep EasyLocalization in lockstep with AppSettings. Language taps often
    // happen from a sheet or list that rebuilds (or disposes) right after a
    // theme change; syncing here — under EasyLocalization, above MaterialApp —
    // survives that and prevents "font flipped but strings did not" states.
    ref.listen(appSettingsProvider.select((s) => s.language), (previous, next) {
      if (previous == next) return;
      if (context.locale == next.locale) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && context.locale != next.locale) {
          context.setLocale(next.locale);
        }
      });
    });

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
        locale: settings.language.locale,
        routerConfig: router,
        // `LocaleKeys.x.tr()` reads a singleton and does not subscribe the
        // widget to locale changes. Keying the tree by language forces every
        // open screen (shell, sticky State objects, …) to rebuild with the
        // new translations instead of leaving stale copy on the same page.
        builder: (context, routed) => KeyedSubtree(
          key: ValueKey(settings.language.code),
          child: SplashGate(child: routed ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}
