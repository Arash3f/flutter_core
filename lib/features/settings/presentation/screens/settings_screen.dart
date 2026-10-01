import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/providers/app_settings_provider.dart';
import 'package:flutter_core/core/utils/constants/enum.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/widgets/app_ui.dart';
import 'package:flutter_core/core/widgets/appearance_controls.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demonstrates a feature that only has a presentation layer: there is no
/// domain rule or data source beyond the shared settings provider.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    // No AppBar: the screen lives inside AdaptiveShell, which owns it.
    return ListView(
      padding: const EdgeInsets.only(bottom: TSizes.lg),
      children: [
        AppPageHeader(title: LocaleKeys.settingsTitle.tr()),
        _SectionTitle(LocaleKeys.settingsTheme.tr()),
        for (final mode in ThemeMode.values)
          _ChoiceTile(
            icon: themeModeIcon(mode),
            label: themeModeLabel(mode),
            isSelected: settings.themeMode == mode,
            onTap: () => notifier.setThemeMode(mode),
          ),
        const Divider(height: TSizes.lg),
        _SectionTitle(LocaleKeys.settingsLanguage.tr()),
        for (final language in LanguageList.values)
          _ChoiceTile(
            icon: Icons.translate_rounded,
            label: language.label,
            isSelected: settings.language == language,
            onTap: () => setAppLanguage(context, ref, language),
          ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
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
  const _SectionTitle(this.title);

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
