# Flutter core

Base project for all Flutter projects. It ships theming, localization,
storage, networking, auth, navigation, an adaptive shell and worked Clean
Architecture + Riverpod features, ready to copy.

- **State management / DI** — [Riverpod 3](https://riverpod.dev) (no code generation)
- **Architecture** — feature-first Clean Architecture, see [`lib/features/README.md`](./lib/features/README.md)
- **Networking** — Dio (REST) and graphql_flutter, with token refresh and error mapping, see [`lib/core/network`](./lib/core/network/README.md)
- **Auth** — login, session restore, refresh, logout, permissions, sessions, see [`lib/features/auth`](./lib/features/auth/README.md)
- **Navigation** — go_router with an auth guard, see [`lib/core/router`](./lib/core/router/README.md)
- **Adaptive layout** — bottom navigation on phones, navigation rail on tablets and desktop (Material 3 breakpoints)
- **Localization** — easy_localization + flutter_localizations (`en`, `fa`, RTL)
- **Storage** — SharedPreferences and flutter_secure_storage behind one helper
- **Responsive** — flutter_screenutil, design size 390×844

## Requirements

| Tool | Version |
|---|---|
| Flutter | ≥ 3.35 (stable) |
| Dart | ≥ 3.12 |
| JDK | 17+ (Android builds) |

## Getting started

```shell
flutter pub get
flutter run                                   # talks to http://127.0.0.1:8000 in debug
flutter run --dart-define=AUTH_ENABLED=false  # no backend yet: skip login
```

### Build-time configuration

| `--dart-define` | Default | Purpose |
|---|---|---|
| `API_BASE_URL` | debug `http://127.0.0.1:8000`, release `https://api.example.com` | backend origin |
| `GRAPHQL_PATH` | `/graphql` | GraphQL endpoint path |
| `AUTH_ENABLED` | `true` | `false` disables login and the auth guard |

Edit the release URL in `lib/core/utils/constants/api.dart` when a project
starts.

## Important commands

### Daily

```shell
flutter pub get          # install/update packages after pubspec changes
flutter run              # run on a connected device / emulator / Chrome
flutter devices          # list available devices
flutter clean            # when builds act weird; then run pub get again
```

### Quality (before push)

```shell
dart format lib test tool
flutter analyze
flutter test
```

### App icon

```shell
dart run tool/gen_icon.dart        # placeholder icon from code -> assets/icons/
dart run flutter_launcher_icons    # writes platform icons from assets/icons/
```

Replace `assets/icons/app_icon.png` and `app_icon_foreground.png` with real
artwork when it exists, then rerun the second command.

### Code generation (only when needed)

```shell
# after changing assets in pubspec.yaml
dart run build_runner build --delete-conflicting-outputs

# after changing translation JSON files
dart run easy_localization:generate -S assets/translations -O lib/core/utils/l10n -o locale_keys.g.dart -f keys
```

### Debug / build

```shell
flutter run -d chrome          # web
flutter run -d windows         # desktop (requires Visual Studio)
flutter build apk --debug      # Android APK
flutter logs                   # device logs
```

### Tooling health

```shell
flutter doctor -v
flutter --version
java -version                  # JDK 17+
echo $env:JAVA_HOME            # PowerShell
echo $env:ANDROID_HOME
```

### Slow pub.dev (optional mirrors)

```powershell
# temporary Runflare mirrors
$env:PUB_HOSTED_URL = "https://pub.runflare.com"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.runflare.com"

# restore defaults
Remove-Item Env:PUB_HOSTED_URL -ErrorAction SilentlyContinue
Remove-Item Env:FLUTTER_STORAGE_BASE_URL -ErrorAction SilentlyContinue
```

If pub.dev is unreachable but packages were downloaded before, resolve from
the local cache:

```powershell
$env:PUB_CACHE = "$env:LOCALAPPDATA\Pub\Cache"
flutter pub get --offline
```

### Git + commit (Husky)

```shell
git status
git add .
npx cz                         # interactive Commitizen commit
# or: git commit -m "..."
```

### Windows note

If `flutter pub get` complains about symlinks, enable **Developer Mode**
(`start ms-settings:developers`), then run `flutter pub get` again.

## Project layout

```
lib/
├── main.dart                  bootstrap: SharedPrefs + EasyLocalization + desktop window + ProviderScope
├── app.dart                   MaterialApp.router, theme, locale and SplashGate wiring
├── core/
│   ├── error/                 Failure (domain) and Exception (data) types
│   ├── network/               REST + GraphQL clients, token refresh, error mapping
│   ├── providers/             app-wide Riverpod providers (theme, language)
│   ├── router/                go_router routes and auth guard
│   ├── usecase/               UseCase contract
│   ├── widgets/               adaptive shell, splash, page/async/feedback widgets
│   └── utils/
│       ├── colors/            palette, gradients, brightness-dependent colors
│       ├── constants/         sizes, enums, api config, feature flags
│       ├── device/            breakpoints, screen size and platform helpers
│       ├── formatters/        date formatting
│       ├── gen/               generated assets and fonts
│       ├── json/              tolerant JSON reader for models
│       ├── l10n/              generated LocaleKeys
│       ├── local_storage/     SharedPrefs, SecureStorage, AppStorageHelper
│       ├── logging/           LoggerService
│       ├── theme/             light and dark ThemeData
│       └── validators/        form validators
└── features/
    ├── auth/                  login, session, refresh, permissions (REST or GraphQL)
    ├── profile/               account, password change, sessions (uses auth's use cases)
    ├── todo/                  full domain / data / presentation example
    └── settings/              presentation-only example
test/                          unit tests: network, breakpoints, use cases
tool/gen_icon.dart             placeholder launcher icon generator
```

`lib/core/network`, `lib/core/router`, `lib/core/widgets` and every folder
under `lib/core/utils/` have their own README with usage examples.

## Architecture

Dependencies point inwards only:

```
presentation ──▶ domain ◀── data
```

`domain` is pure Dart. Data sources throw exceptions, repositories translate
them into `Failure`s, and `AsyncValue.guard` turns those into `AsyncError` for
the UI. The full rationale and a step-by-step guide for adding a feature is in
[`lib/features/README.md`](./lib/features/README.md).

## Theming

`TAppTheme.lightTheme(language)` / `darkTheme(language)` compose the per-widget
themes in `core/utils/theme/custom_themes/`. The font family follows the
language (IranSans for `fa`, OpenSans otherwise).

The active `ThemeMode` and language are persisted and exposed through
`appSettingsProvider`; the Settings tab changes both at runtime.

Because the text styles use `.sp`, the themes are built **inside**
`ScreenUtilInit`'s builder — see `app.dart`.

## Git Hooks
:star2: Used git hooks for better commit and automate tasks before pushing to a repository :v:

- Read more [GitHooks](./readme/GitHooks.md)
