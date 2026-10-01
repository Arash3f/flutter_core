import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/providers/app_settings_provider.dart';
import 'package:flutter_core/core/utils/constants/enum.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Compact language / theme switch for app bars.
///
/// Shows the *current* language and theme: tap the language to cycle through
/// [LanguageList], tap the theme icon to cycle system -> light -> dark.
class AppearanceToolbar extends ConsumerWidget {
  const AppearanceToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Material(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: settings.language.label,
              child: InkWell(
                onTap: () => setAppLanguage(
                  context,
                  ref,
                  _next(LanguageList.values, settings.language),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    settings.language.code.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 18,
              child: VerticalDivider(
                width: 1,
                thickness: 1,
                color: scheme.outlineVariant,
              ),
            ),
            Tooltip(
              message: themeModeLabel(settings.themeMode),
              child: InkWell(
                onTap: () => ref
                    .read(appSettingsProvider.notifier)
                    .setThemeMode(_next(ThemeMode.values, settings.themeMode)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Icon(themeModeIcon(settings.themeMode), size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full language + theme picker, for the login page, the "More" sheet and
/// anywhere else that has room.
class AppearancePanel extends ConsumerWidget {
  const AppearancePanel({super.key, this.showTitle = true});

  final bool showTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showTitle) ...[
              Text(LocaleKeys.navAppearance.tr(), style: text.titleSmall),
              const SizedBox(height: 12),
            ],
            Text(LocaleKeys.settingsLanguage.tr(), style: text.labelMedium),
            const SizedBox(height: 8),
            SegmentedButton<LanguageList>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: [
                for (final language in LanguageList.values)
                  ButtonSegment(value: language, label: Text(language.label)),
              ],
              selected: {settings.language},
              onSelectionChanged: (value) =>
                  setAppLanguage(context, ref, value.first),
            ),
            const SizedBox(height: 14),
            Text(LocaleKeys.settingsTheme.tr(), style: text.labelMedium),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              expandedInsets: EdgeInsets.zero,
              segments: [
                for (final mode in ThemeMode.values)
                  ButtonSegment(
                    value: mode,
                    icon: Icon(themeModeIcon(mode), size: 20),
                    tooltip: themeModeLabel(mode),
                  ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (value) => ref
                  .read(appSettingsProvider.notifier)
                  .setThemeMode(value.first),
            ),
            const SizedBox(height: 6),
            Text(
              themeModeLabel(settings.themeMode),
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Persists [language] and keeps EasyLocalization aligned with it.
///
/// Always change the language through here (or `AppSettingsNotifier`), never
/// by calling `context.setLocale` alone — the App widget also listens to
/// [appSettingsProvider] so a theme rebuild cannot leave locale half-applied.
Future<void> setAppLanguage(
  BuildContext context,
  WidgetRef ref,
  LanguageList language,
) async {
  // Apply EasyLocalization first while this context is still mounted. Theme
  // changes rebuild MaterialApp; doing setLocale after the provider update
  // often runs against a disposed sheet/list context and silently no-ops.
  if (context.mounted && context.locale != language.locale) {
    await context.setLocale(language.locale);
  }
  await ref.read(appSettingsProvider.notifier).setLanguage(language);
}

String themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.system => LocaleKeys.settingsThemeSystem.tr(),
  ThemeMode.light => LocaleKeys.settingsThemeLight.tr(),
  ThemeMode.dark => LocaleKeys.settingsThemeDark.tr(),
};

IconData themeModeIcon(ThemeMode mode) => switch (mode) {
  ThemeMode.system => Icons.brightness_auto_outlined,
  ThemeMode.light => Icons.light_mode_outlined,
  ThemeMode.dark => Icons.dark_mode_outlined,
};

T _next<T>(List<T> values, T current) =>
    values[(values.indexOf(current) + 1) % values.length];
