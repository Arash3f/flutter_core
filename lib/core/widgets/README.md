# Shared widgets

Building blocks with no feature knowledge. Anything used by two or more
features belongs here; anything used by one stays in that feature's
`presentation/widgets/`.

## App frame

| Widget | File | What it does |
|---|---|---|
| `SplashGate` | [`splash_gate.dart`](./splash_gate.dart) | shows `SplashScreen` until bootstrap (session restore) finishes, at least `minDisplay` |
| `SplashScreen` | [`splash_screen.dart`](./splash_screen.dart) | animated brand splash; honors "reduce motion" |
| `AdaptiveShell` | [`adaptive_shell.dart`](./adaptive_shell.dart) | `NavigationBar` below 840dp, `NavigationRail` above; "More" sheet on phones |

`AdaptiveShell` reads its tabs from `AdaptiveShell.destinations`. Each
`ShellDestination` can be hidden with `requiresAuth` (signed-out users) or
`permission` (users without that permission).

## Page building blocks

[`app_ui.dart`](./app_ui.dart):

| Widget / function | Use |
|---|---|
| `AppPageHeader` | page title + subtitle + trailing action. Use it instead of an `AppBar` inside the shell, which already has one |
| `LiveSearchField` | search box with a clear button; reports every keystroke |
| `appQueryMatches(query, fields)` | case-insensitive client-side filter |
| `AppEntityCard` | outlined list row: leading, title, subtitle, trailing |
| `AppInitialsAvatar` / `AppIconBadge` | leading slots for `AppEntityCard` |
| `AppFilterPills<T>` | horizontally scrolling single-choice chips (filters, sub-tabs) |
| `AppSectionCard` | outlined surface that groups a form or a settings block |
| `AppMark` | Arash Alfooneh ribbon mark (`assets/brand/mark-blue.png`) |
| `AppAtmosphere` | soft brand gradient behind full-screen pages |
| `appMutedOf(context)` | muted text color |

## Async state and feedback

```dart
AsyncValueView<List<Product>>(
  value: ref.watch(productsProvider),
  onRetry: () => ref.invalidate(productsProvider),
  builder: (context, products) => products.isEmpty
      ? const EmptyState(icon: Icons.inbox_outlined, title: 'No products')
      : ProductList(products),
);
```

- [`async_value_view.dart`](./async_value_view.dart): `AsyncValueView`,
  `ErrorView`, `EmptyState`.
- [`feedback.dart`](./feedback.dart):
  - `showConfirmDialog` (set `destructive: true` for irreversible actions)
  - `showAppToast`
  - `showErrorToast`, which localizes any `Failure` through `describeError`

## Appearance and permissions

- [`appearance_controls.dart`](./appearance_controls.dart):
  - `AppearanceToolbar` (compact, for app bars)
  - `AppearancePanel` (full picker)
  - `setAppLanguage`: always change the language through it, because
    easy_localization keeps its own copy of the locale
- [`permission_gate.dart`](./permission_gate.dart): `PermissionGate` hides a
  widget when `allowed` is false. Hiding a button is a convenience, not
  security; the backend must still enforce the permission.

```dart
PermissionGate(
  allowed: ref.watch(authSessionProvider).value?.hasPermission('user_create') ?? false,
  child: FilledButton(onPressed: create, child: const Text('New user')),
);
```
