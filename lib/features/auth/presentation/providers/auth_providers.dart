import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_core/core/error/error_message.dart';
import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/network/network_providers.dart';
import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/core/utils/constants/feature_flags.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_core/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_core/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_core/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_core/features/auth/domain/usecases/change_password.dart';
import 'package:flutter_core/features/auth/domain/usecases/get_current_user.dart';
import 'package:flutter_core/features/auth/domain/usecases/login.dart';
import 'package:flutter_core/features/auth/domain/usecases/logout.dart';
import 'package:flutter_core/features/auth/domain/usecases/refresh_session.dart';
import 'package:flutter_core/features/auth/domain/usecases/restore_session.dart';
import 'package:flutter_core/features/auth/domain/usecases/sessions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ---------------------------------------------------------------- data layer

/// Swap for `AuthGraphQLDataSource(ref.watch(graphQLClientProvider))` when the
/// backend speaks GraphQL. Nothing else changes.
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthRestDataSource(ref.watch(restClientProvider)),
);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>(
  (ref) => const AuthLocalDataSourceImpl(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
  ),
);

// -------------------------------------------------------------- domain layer

final loginUseCaseProvider = Provider<Login>(
  (ref) => Login(ref.watch(authRepositoryProvider)),
);

final logoutUseCaseProvider = Provider<Logout>(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

final logoutAllUseCaseProvider = Provider<LogoutAll>(
  (ref) => LogoutAll(ref.watch(authRepositoryProvider)),
);

final refreshSessionUseCaseProvider = Provider<RefreshSession>(
  (ref) => RefreshSession(ref.watch(authRepositoryProvider)),
);

final restoreSessionUseCaseProvider = Provider<RestoreSession>(
  (ref) => RestoreSession(ref.watch(authRepositoryProvider)),
);

final getCurrentUserUseCaseProvider = Provider<GetCurrentUser>(
  (ref) => GetCurrentUser(ref.watch(authRepositoryProvider)),
);

final changePasswordUseCaseProvider = Provider<ChangePassword>(
  (ref) => ChangePassword(ref.watch(authRepositoryProvider)),
);

final getSessionsUseCaseProvider = Provider<GetSessions>(
  (ref) => GetSessions(ref.watch(authRepositoryProvider)),
);

final revokeSessionUseCaseProvider = Provider<RevokeSession>(
  (ref) => RevokeSession(ref.watch(authRepositoryProvider)),
);

// ---------------------------------------------------------- presentation layer

enum AuthStatus { unknown, authenticated, anonymous }

class AuthState extends Equatable {
  const AuthState._({required this.status, this.user, this.errorMessage});

  const AuthState.anonymous({String? errorMessage})
    : this._(status: AuthStatus.anonymous, errorMessage: errorMessage);

  const AuthState.authenticated(AuthUser user)
    : this._(status: AuthStatus.authenticated, user: user);

  final AuthStatus status;
  final AuthUser? user;

  /// Already localized; shown on the login screen.
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool hasPermission(String permission) =>
      user?.hasPermission(permission) ?? false;

  @override
  List<Object?> get props => [status, user, errorMessage];
}

/// The app-wide session. Watch it for the current user; call its methods to
/// log in and out.
///
/// On build it binds the refresh use case into the network layer and listens
/// for refresh failures coming back from it, so an expired session anywhere
/// in the app flips this to anonymous and the router redirects to login.
class AuthSessionNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    if (!FeatureFlags.authEnabled) return const AuthState.anonymous();

    final refresher = ref.watch(tokenRefresherProvider)
      ..bind(
        () => ref.read(refreshSessionUseCaseProvider).call(const NoParams()),
      );
    ref.onDispose(refresher.unbind);

    ref.listen(authFailureSignalProvider, (_, _) {
      state = const AsyncData(AuthState.anonymous());
    });

    try {
      final user = await ref
          .read(restoreSessionUseCaseProvider)
          .call(const NoParams());
      return user == null
          ? const AuthState.anonymous()
          : AuthState.authenticated(user);
    } on Failure catch (failure) {
      return AuthState.anonymous(errorMessage: describeError(failure));
    }
  }

  /// Returns `true` on success. On failure the localized reason is in
  /// `state.value?.errorMessage`.
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(() async {
      await ref
          .read(loginUseCaseProvider)
          .call(LoginParams(username: username, password: password));
      final user = await ref
          .read(getCurrentUserUseCaseProvider)
          .call(const NoParams());
      return AuthState.authenticated(user);
    });
    if (!ref.mounted) return false;

    if (result case AsyncError(:final error)) {
      state = AsyncData(AuthState.anonymous(errorMessage: _loginError(error)));
      return false;
    }
    state = result;
    return true;
  }

  Future<void> logout() async {
    await ref.read(logoutUseCaseProvider).call(const NoParams());
    if (ref.mounted) state = const AsyncData(AuthState.anonymous());
  }

  Future<void> logoutAll() async {
    await ref.read(logoutAllUseCaseProvider).call(const NoParams());
    if (ref.mounted) state = const AsyncData(AuthState.anonymous());
  }

  /// Re-fetches the user after a profile or permission change.
  Future<void> refreshUser() async {
    final user = await ref
        .read(getCurrentUserUseCaseProvider)
        .call(const NoParams());
    if (ref.mounted) state = AsyncData(AuthState.authenticated(user));
  }

  /// A 401 on login means bad credentials, not an expired session.
  static String _loginError(Object error) => error is AuthFailure
      ? LocaleKeys.errorInvalidCredentials.tr()
      : describeError(error);
}

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionNotifier, AuthState>(
      AuthSessionNotifier.new,
    );

/// Synchronous status for the router. `unknown` only until the first build
/// completes; later reloads keep the previous status.
final authStatusProvider = Provider<AuthStatus>(
  (ref) => ref.watch(authSessionProvider).value?.status ?? AuthStatus.unknown,
);
