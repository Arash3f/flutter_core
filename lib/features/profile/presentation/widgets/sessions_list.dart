import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/formatters/formatter.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/widgets/app_ui.dart';
import 'package:flutter_core/core/widgets/async_value_view.dart';
import 'package:flutter_core/core/widgets/feedback.dart';
import 'package:flutter_core/features/auth/domain/entities/user_session.dart';
import 'package:flutter_core/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionsList extends ConsumerWidget {
  const SessionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView<List<UserSession>>(
      value: ref.watch(sessionsProvider),
      onRetry: () => ref.invalidate(sessionsProvider),
      builder: (context, sessions) {
        if (sessions.isEmpty) {
          return EmptyState(
            icon: Icons.devices_other_outlined,
            title: LocaleKeys.profileSessionsEmpty.tr(),
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.refresh(sessionsProvider.future),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            itemCount: sessions.length,
            itemBuilder: (context, index) =>
                _SessionCard(session: sessions[index]),
          ),
        );
      },
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.session});

  final UserSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final created = session.createdAt;
    final details = [
      if (session.isCurrent) LocaleKeys.profileSessionCurrent.tr(),
      ?session.ipAddress,
      if (created != null)
        Formatter.date.getLocalizedDate(
          created.toLocal(),
          format: 'yyyy-MM-dd HH:mm',
          locale: context.locale.languageCode,
        ),
    ];

    return AppEntityCard(
      leading: AppIconBadge(
        icon: session.isCurrent
            ? Icons.smartphone_rounded
            : Icons.devices_other_rounded,
      ),
      title: session.userAgent ?? session.id,
      subtitle: details.join(' · '),
      trailing: session.isCurrent
          ? null
          : TextButton(
              onPressed: () async {
                try {
                  await revokeSession(ref, session.id);
                } on Object catch (error) {
                  if (context.mounted) showErrorToast(context, error);
                }
              },
              child: Text(LocaleKeys.profileSessionRevoke.tr()),
            ),
    );
  }
}
