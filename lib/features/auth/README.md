# Auth

Token-based authentication: login, session restore on startup, transparent
token refresh, logout (this device or all devices), current user and
permissions, password change and session management.

```
domain/
├── entities/        AuthUser (permissions, displayName), UserSession
├── repositories/    AuthRepository - no tokens cross this boundary
└── usecases/        Login, Logout, LogoutAll, RefreshSession, RestoreSession,
                     GetCurrentUser, ChangePassword, GetSessions, RevokeSession
data/
├── models/          JSON <-> entity; accept snake_case and camelCase keys
├── datasources/     AuthRestDataSource (default), AuthGraphQLDataSource,
│                    AuthLocalDataSource (token storage)
└── repositories/    AuthRepositoryImpl - maps errors to Failures
presentation/
├── providers/       wiring + AuthSessionNotifier (the app-wide session)
└── screens/         LoginScreen
```

The profile screen (`features/profile`) is built on these use cases and has no
data layer of its own.

## Using the session

```dart
final auth = ref.watch(authSessionProvider).value;
final user = auth?.user;                     // AuthUser?
final canEdit = auth?.hasPermission('user_update') ?? false;

await ref.read(authSessionProvider.notifier).logout();
```

Never navigate after login or logout. Change the session and the router's
redirect handles it (see [`core/router`](../../core/router/README.md)).

## Startup

`SplashGate` waits for `authSessionProvider`. `RestoreSession` then decides:

| Situation | Result |
|---|---|
| no stored token | anonymous |
| token valid (possibly after a silent refresh) | authenticated |
| token rejected and refresh failed | tokens cleared, anonymous |
| offline / server down | anonymous for now, **tokens kept** |

The last row matters. A user who opens the app without a connection must not
be logged out.

## Backend contract (REST)

Paths live in `AuthEndpoints`. Adjust them, and the body keys in
`AuthRestDataSource`, to your API:

| Method | Path | Body | Response |
|---|---|---|---|
| POST | `/auth/login` | `{username, password}` | `{access_token, refresh_token, token_type}` |
| POST | `/auth/refresh` | `{refresh_token}` | same as login |
| POST | `/auth/logout` | – | – |
| POST | `/auth/logout-all` | – | – |
| GET | `/auth/me` | – | `{id, username, fullname, role_id, role_name, permissions: []}` |
| PUT | `/auth/password` | `{current_password, new_password}` | – |
| GET | `/auth/sessions` | – | `[{id, user_agent, ip_address, created_at, expires_at, is_current}]` |
| DELETE | `/auth/sessions/{id}` | – | – |

Errors follow the contract in [`core/network`](../../core/network/README.md).
A 401 on login is shown as "invalid credentials"; anywhere else it means the
session expired.

## Switching to GraphQL

Change one provider in `presentation/providers/auth_providers.dart`:

```dart
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>(
  (ref) => AuthGraphQLDataSource(ref.watch(graphQLClientProvider)),
);
```

Then edit the documents at the top of `auth_graphql_data_source.dart` to match
your schema. Keep the operation names `Login` and `RefreshToken`, or update
`RefreshLink.skipOperations` to match.

## Running without a backend

```shell
flutter run --dart-define=AUTH_ENABLED=false
```

The session stays anonymous, the login route redirects home, and tabs marked
`requiresAuth` are hidden. Use this to build UI before the API exists.

## Permissions

`AuthUser.permissions` is a list of strings from `/auth/me`. Define them as
constants once per project instead of scattering string literals:

```dart
abstract final class Permissions {
  static const userRead = 'user_read';
  static const userCreate = 'user_create';
}
```

Use them with `PermissionGate`, or set `ShellDestination.permission` to hide a
tab. The backend remains the authority; the client only hides what the user
cannot use.

## Removing auth

1. Delete `features/auth` and `features/profile`.
2. Drop their routes from `app_router.dart` and the guard in `_redirect`.
3. Drop the profile destination and the logout buttons from `AdaptiveShell`.
4. Remove the `authSessionProvider` wait from `SplashGate`.
5. Remove the `tokenRefresher` / `authFailureSignal` wiring from
   `network_providers.dart`.
