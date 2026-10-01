# Router

Navigation uses [go_router](https://pub.dev/packages/go_router), exposed as
`appRouterProvider` and plugged into `MaterialApp.router` in `app.dart`.

| File | Purpose |
|---|---|
| [`app_routes.dart`](./app_routes.dart) | path constants and the set of public (no-login) routes |
| [`app_router.dart`](./app_router.dart) | route table, auth redirect, 404 page |

`app_router.dart` is the composition root for navigation: it is the only file
in `core/` that imports feature screens. Features never import each other's
screens. They navigate by path:

```dart
context.go(AppRoutes.profile);   // replace the stack
context.push(AppRoutes.profile); // push on top (back button returns)
```

## Route tree

```
/login                 LoginScreen        (public)
ShellRoute             AdaptiveShell      (navigation bar / rail)
├── /                  TodoScreen
├── /profile           ProfileScreen
└── /settings          SettingsScreen
```

## Auth guard

`_redirect` runs on every navigation and again whenever `authStatusProvider`
changes:

| Auth status | On a public route | On a protected route |
|---|---|---|
| `unknown` (restoring) | stay | stay (`SplashGate` covers the screen) |
| `anonymous` | stay | go to `/login` |
| `authenticated` | go to `/` | stay |

Screens never navigate after login or logout themselves; they change the
session and the redirect does the rest. That is also why a refresh failure
deep in the network layer lands on login without any extra code.

With `--dart-define=AUTH_ENABLED=false` the guard is off and `/login`
redirects home. This is handy for UI work before the backend exists.

## Adding a page

1. Add the path to `AppRoutes`. If it needs no login, add it to `public` too.
2. Add a `GoRoute`:
   - inside the `ShellRoute` to keep the navigation chrome
   - at the top level for full-screen pages
3. If it is a tab, add a `ShellDestination` to `AdaptiveShell.destinations`.

Path parameters:

```dart
GoRoute(
  path: '/products/:id',
  builder: (context, state) =>
      ProductScreen(id: state.pathParameters['id']!),
),
```
