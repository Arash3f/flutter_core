import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/router/app_routes.dart';
import 'package:flutter_core/core/utils/constants/feature_flags.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/widgets/adaptive_shell.dart';
import 'package:flutter_core/core/widgets/async_value_view.dart';
import 'package:flutter_core/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_core/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_core/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter_core/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_core/features/todo/presentation/screens/todo_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// The app's [GoRouter].
///
/// This file is the composition root for navigation: it is the one place in
/// `core/` allowed to import feature screens. Features never import each
/// other's screens; they navigate by path through [AppRoutes].
///
/// Auth guard: [_redirect] runs on every navigation and whenever the session
/// status changes ([_AuthRefresh]), so logging out anywhere - including a
/// failed token refresh deep inside the network layer - lands on login.
final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: refresh,
    redirect: (context, state) => _redirect(ref, state),
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(),
      body: EmptyState(
        icon: Icons.explore_off_outlined,
        title: state.uri.path,
        actionLabel: LocaleKeys.navHome.tr(),
        onAction: () => context.go(AppRoutes.home),
      ),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AdaptiveShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const TodoScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

String? _redirect(Ref ref, GoRouterState state) {
  final isPublic = AppRoutes.public.contains(state.matchedLocation);

  if (!FeatureFlags.authEnabled) {
    return isPublic ? AppRoutes.home : null;
  }

  return switch (ref.read(authStatusProvider)) {
    // Still restoring the session; SplashGate is covering the screen.
    AuthStatus.unknown => null,
    AuthStatus.anonymous => isPublic ? null : AppRoutes.login,
    AuthStatus.authenticated => isPublic ? AppRoutes.home : null,
  };
}

/// Re-runs the redirect whenever the auth status changes.
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Ref ref) {
    ref.listen<AuthStatus>(authStatusProvider, (_, _) => notifyListeners());
  }
}
