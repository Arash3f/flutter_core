import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/widgets/app_ui.dart';
import 'package:flutter_core/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountOverview extends ConsumerWidget {
  const AccountOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).value?.user;
    if (user == null) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;

    return RefreshIndicator(
      onRefresh: () => ref.read(authSessionProvider.notifier).refreshUser(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Center(child: AppInitialsAvatar(label: user.displayName, radius: 42)),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            textAlign: TextAlign.center,
            style: text.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '@${user.username}',
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: appMutedOf(context)),
          ),
          const SizedBox(height: 22),
          AppSectionCard(
            child: Column(
              children: [
                if (user.roleName != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.badge_outlined),
                    title: Text(LocaleKeys.profileRole.tr()),
                    subtitle: Text(user.roleName!),
                  ),
                  const Divider(),
                ],
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.security_outlined),
                  title: Text(LocaleKeys.profilePermissions.tr()),
                  subtitle: user.permissions.isEmpty
                      ? Text(LocaleKeys.profileNoPermissions.tr())
                      : Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final permission in user.permissions)
                                Chip(
                                  label: Text(permission),
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
