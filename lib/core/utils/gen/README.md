
# Flutter Gen

[flutter_gen](https://pub.dev/packages/flutter_gen) turns the `assets` and
`fonts` entries of `pubspec.yaml` into typed Dart, so a renamed file becomes a
compile error instead of a runtime blank.

Configuration lives under `flutter_gen:` in `pubspec.yaml`; output goes to this
directory.

## Generate files

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Usage/Examples

```dart
import 'package:flutter_core/core/utils/gen/assets.gen.dart';
import 'package:flutter_core/core/utils/gen/fonts.gen.dart';

Assets.translations.en;   // 'assets/translations/en.json'
FontFamily.iranSans;      // 'IranSans'
```

## Notes

- `*.gen.dart` files are generated. Edit `pubspec.yaml` and re-run the command;
  never edit them by hand. They are excluded from analysis in
  `analysis_options.yaml`.
- Every directory listed under `flutter/assets` must exist on disk, otherwise
  `flutter pub get` fails. Empty directories keep a `.gitkeep`.
- The `flutter_gen.integrations` block (svg, rive, lottie, …) is intentionally
  empty: enabling an integration whose package is not in `dependencies`
  generates code that does not compile.
