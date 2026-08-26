import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/providers/app_settings_provider.dart';
import 'package:flutter_core/core/utils/theme/theme.dart';
import 'package:flutter_core/core/widgets/main_wrapper.dart';
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

    return ScreenUtilInit(
      designSize: designSize,
      minTextAdapt: true,
      splitScreenMode: true,
      // The themes read `.sp`, so they have to be built inside this builder,
      // after ScreenUtil has been configured.
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Core',
        themeMode: settings.themeMode,
        theme: TAppTheme.lightTheme(settings.language),
        darkTheme: TAppTheme.darkTheme(settings.language),
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home: child,
      ),
      child: const SplashGate(child: MainWrapper()),
    );
  }
}
