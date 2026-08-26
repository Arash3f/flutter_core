# Flutter core

Base project for all Flutter projects: theming, localization, storage, logging
and a worked Clean Architecture + Riverpod feature, ready to copy.

- **State management / DI** — [Riverpod 3](https://riverpod.dev) (no code generation)
- **Architecture** — feature-first Clean Architecture, see [`lib/features/README.md`](./lib/features/README.md)
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
flutter run
```

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
dart format lib
flutter analyze
```

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
├── main.dart                  bootstrap: SharedPrefs + EasyLocalization + ProviderScope
├── app.dart                   MaterialApp, theme and locale wiring
├── core/
│   ├── error/                 Failure (domain) and Exception (data) types
│   ├── providers/             app-wide Riverpod providers (theme, language)
│   ├── usecase/               UseCase contract
│   ├── widgets/               shared widgets, bottom-navigation shell
│   └── utils/
│       ├── colors/            palette, gradients, brightness-dependent colors
│       ├── constants/         sizes, enums, api constants
│       ├── device/            screen size and platform helpers
│       ├── formatters/        date formatting
│       ├── gen/               generated assets and fonts
│       ├── l10n/              generated LocaleKeys
│       ├── local_storage/     SharedPrefs, SecureStorage, AppStorageHelper
│       ├── logging/           LoggerService
│       ├── theme/             light and dark ThemeData
│       └── validators/        form validators
└── features/
    ├── todo/                  full domain / data / presentation example
    └── settings/              presentation-only example
```

Each folder under `lib/core/utils/` has its own README with usage examples.

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
