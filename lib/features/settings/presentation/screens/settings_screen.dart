import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/providers/app_settings_provider.dart';
import 'package:flutter_core/core/utils/constants/enum.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demonstrates a feature that only has a presentation layer: there is no
/// domain rule or data source beyond the shared settings provider.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.settingsTitle.tr())),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: TSizes.sm),
        children: [
          _SectionTitle(LocaleKeys.settingsTheme.tr()),
          for (final mode in ThemeMode.values)
            _ChoiceTile(
              label: _themeLabel(mode),
              isSelected: settings.themeMode == mode,
              onTap: () => notifier.setThemeMode(mode),
            ),
          const Divider(height: TSizes.lg),
          _SectionTitle(LocaleKeys.settingsLanguage.tr()),
          for (final language in LanguageList.values)
            _ChoiceTile(
              label: language.label,
              isSelected: settings.language == language,
              onTap: () async {
                await notifier.setLanguage(language);
                // easy_localization keeps its own locale, so it has to be told
                // about the change as well.
                if (context.mounted) await context.setLocale(language.locale);
              },
            ),
        ],
      ),
    );
  }

  static String _themeLabel(ThemeMode mode) => switch (mode) {
        ThemeMode.system => LocaleKeys.settingsThemeSystem.tr(),
        ThemeMode.light => LocaleKeys.settingsThemeLight.tr(),
        ThemeMode.dark => LocaleKeys.settingsThemeDark.tr(),
      };
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      selected: isSelected,
      onTap: onTap,
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TSizes.md,
        TSizes.sm,
        TSizes.md,
        TSizes.xs,
      ),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
