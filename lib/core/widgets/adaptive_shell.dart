import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/router/app_routes.dart';
import 'package:flutter_core/core/utils/constants/feature_flags.dart';
import 'package:flutter_core/core/utils/device/breakpoints.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/widgets/app_ui.dart';
import 'package:flutter_core/core/widgets/appearance_controls.dart';
import 'package:flutter_core/core/widgets/feedback.dart';
import 'package:flutter_core/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// One entry in the shell navigation.
class ShellDestination {
  const ShellDestination({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.labelKey,
    this.permission,
    this.requiresAuth = false,
    this.exact = false,
  });

  final String path;
  final IconData icon;
  final IconData selectedIcon;

  /// Locale key, translated at build time so a language switch applies.
  final String labelKey;

  /// Hidden unless the signed-in user has this permission.
  final String? permission;

  /// Hidden when `FeatureFlags.authEnabled` is off (e.g. Profile).
  final bool requiresAuth;

  /// Match [path] exactly instead of as a prefix. Needed for `/`, which is a
  /// prefix of every route.
  final bool exact;
}

/// Scaffold around every signed-in screen, adapting to the window width:
///
/// - compact / medium (< 840dp): app bar + bottom [NavigationBar]; the last
///   item opens a "More" sheet with the user card, appearance and logout
/// - expanded / large: app bar + [NavigationRail] (extended at >= 1200dp),
///   logout actions at the bottom of the rail
///
/// Add a tab by adding a [ShellDestination] to [destinations] and a matching
/// `GoRoute` under the `ShellRoute` in `app_router.dart`.
class AdaptiveShell extends ConsumerWidget {
  const AdaptiveShell({required this.child, super.key});

  final Widget child;

  static const List<ShellDestination> destinations = [
    ShellDestination(
      path: AppRoutes.home,
      icon: Icons.check_circle_outline,
      selectedIcon: Icons.check_circle,
      labelKey: LocaleKeys.navTodos,
      exact: true,
    ),
    ShellDestination(
      path: AppRoutes.profile,
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      labelKey: LocaleKeys.navProfile,
      requiresAuth: true,
    ),
    ShellDestination(
      path: AppRoutes.settings,
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      labelKey: LocaleKeys.navSettings,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authSessionProvider).value;
    final location = GoRouterState.of(context).uri.path;
    final width = MediaQuery.sizeOf(context).width;
    final visible = _visible(auth);
    final selected = _selectedIndex(location, visible);

    void goTo(String path) {
      if (location != path) context.go(path);
    }

    final appBar = AppBar(
      title: Row(
        children: [
          const AppMark(size: 32),
          const SizedBox(width: 10),
          Text(LocaleKeys.brand.tr()),
        ],
      ),
      centerTitle: false,
      actions: const [AppearanceToolbar()],
    );

    if (Breakpoints.useBottomNav(width)) {
      return Scaffold(
        appBar: appBar,
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selected < 0 ? visible.length : selected,
          onDestinationSelected: (index) => index < visible.length
              ? goTo(visible[index].path)
              : _openMore(context, ref, auth),
          destinations: [
            for (final dest in visible)
              NavigationDestination(
                icon: Icon(dest.icon),
                selectedIcon: Icon(dest.selectedIcon),
                label: dest.labelKey.tr(),
              ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz),
              label: LocaleKeys.navMore.tr(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          NavigationRail(
            extended: Breakpoints.useExtendedRail(width),
            selectedIndex: selected < 0 ? null : selected,
            onDestinationSelected: (index) => goTo(visible[index].path),
            trailing: FeatureFlags.authEnabled
                ? Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _LogoutButtons(compact: true),
                      ),
                    ),
                  )
                : null,
            destinations: [
              for (final dest in visible)
                NavigationRailDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: Icon(dest.selectedIcon),
                  label: Text(dest.labelKey.tr()),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }

  static List<ShellDestination> _visible(AuthState? auth) {
    return destinations.where((dest) {
      if (dest.requiresAuth && !FeatureFlags.authEnabled) return false;
      final permission = dest.permission;
      if (permission == null) return true;
      return auth?.hasPermission(permission) ?? false;
    }).toList();
  }

  static int _selectedIndex(String location, List<ShellDestination> visible) {
    for (var i = 0; i < visible.length; i++) {
      final dest = visible[i];
      if (location == dest.path) return i;
      if (!dest.exact && location.startsWith('${dest.path}/')) return i;
    }
    return -1;
  }

  static Future<void> _openMore(
    BuildContext context,
    WidgetRef ref,
    AuthState? auth,
  ) {
    final user = auth?.user;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (user != null) ...[
                Row(
                  children: [
                    AppInitialsAvatar(label: user.displayName, radius: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            style: Theme.of(sheetContext).textTheme.titleMedium,
                          ),
                          Text(
                            '@${user.username}',
                            style: Theme.of(sheetContext).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
              const AppearancePanel(),
              if (FeatureFlags.authEnabled) ...[
                const SizedBox(height: 8),
                const Divider(),
                _LogoutButtons(onDone: () => Navigator.pop(sheetContext)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButtons extends ConsumerWidget {
  const _LogoutButtons({this.compact = false, this.onDone});

  /// Icon buttons for the rail instead of list tiles for the sheet.
  final bool compact;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.read(authSessionProvider.notifier);

    Future<void> logoutAll() async {
      final ok = await showConfirmDialog(
        context,
        message: LocaleKeys.confirmLogoutAll.tr(),
        confirmLabel: LocaleKeys.navLogoutAll.tr(),
        destructive: true,
      );
      if (ok) await session.logoutAll();
    }

    if (compact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: LocaleKeys.navLogout.tr(),
            onPressed: session.logout,
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: LocaleKeys.navLogoutAll.tr(),
            onPressed: logoutAll,
            icon: const Icon(Icons.devices_other_outlined),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.logout),
          title: Text(LocaleKeys.navLogout.tr()),
          onTap: () {
            onDone?.call();
            session.logout();
          },
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.devices_other_outlined),
          title: Text(LocaleKeys.navLogoutAll.tr()),
          onTap: () async {
            await logoutAll();
            onDone?.call();
          },
        ),
      ],
    );
  }
}
