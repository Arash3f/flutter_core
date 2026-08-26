
# AppLocalization

The project uses two things together:

- [easy_localization](https://pub.dev/packages/easy_localization) — the app's
  own strings, loaded from JSON
- [flutter_localizations](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
  — the strings inside Material/Cupertino widgets, plus RTL layout

## Config

Where are the translation files ?
`assets/translations/<locale>.json` — one file per locale, named after its
`LanguageList` code (`en.json`, `fa.json`).

Supported locales are declared once in
[`LanguageList`](../constants/enum.dart) and read from there by `main.dart`, so
adding a language means adding an enum value and a JSON file.

`EasyLocalization.ensureInitialized()` is awaited in `main()` before `runApp`.

## How to generate keys ?

Run this after adding or renaming a key. It rewrites `locale_keys.g.dart` from
the JSON files:

```shell
dart run easy_localization:generate -S assets/translations -O lib/core/utils/l10n -o locale_keys.g.dart -f keys
```

- `-S` source directory
- `-O` output directory
- `-o` output file name
- `-f keys` emit the `LocaleKeys` class

## How to change language ?

Go through the settings provider so the choice is persisted, then tell
easy_localization about it:

```dart
await ref.read(appSettingsProvider.notifier).setLanguage(LanguageList.persian);
await context.setLocale(LanguageList.persian.locale);
```

The Settings screen already does both —
see [`settings_screen.dart`](../../../features/settings/presentation/screens/settings_screen.dart).

## Usage/Examples

```dart
import 'package:easy_localization/easy_localization.dart'; /// Use tr
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart'; /// Use LocaleKeys

Text(LocaleKeys.welcome.tr());

/// With placeholders
Text(LocaleKeys.inputRequired.tr(namedArgs: {'fieldName': LocaleKeys.email.tr()}));
```

## Notes

- Every key must exist in **all** locale files. A key that is missing in one of
  them renders as the raw key name at runtime instead of falling back.
- `locale_keys.g.dart` is generated — do not edit it by hand.
