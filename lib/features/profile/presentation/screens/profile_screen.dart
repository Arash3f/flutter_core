import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/widgets/app_ui.dart';
import 'package:flutter_core/features/profile/presentation/widgets/account_overview.dart';
import 'package:flutter_core/features/profile/presentation/widgets/change_password_form.dart';
import 'package:flutter_core/features/profile/presentation/widgets/sessions_list.dart';

enum _ProfileTab { account, password, sessions }

/// Account details, password change and active sessions, as three sub-tabs.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  _ProfileTab _tab = _ProfileTab.account;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPageHeader(title: LocaleKeys.profileTitle.tr()),
        AppFilterPills<_ProfileTab>(
          values: _ProfileTab.values,
          selected: _tab,
          onSelected: (tab) => setState(() => _tab = tab),
          labelOf: (tab) => switch (tab) {
            _ProfileTab.account => LocaleKeys.navProfile.tr(),
            _ProfileTab.password => LocaleKeys.profilePassword.tr(),
            _ProfileTab.sessions => LocaleKeys.profileSessions.tr(),
          },
        ),
        Expanded(
          child: switch (_tab) {
            _ProfileTab.account => const AccountOverview(),
            _ProfileTab.password => const ChangePasswordForm(),
            _ProfileTab.sessions => const SessionsList(),
          },
        ),
      ],
    );
  }
}
