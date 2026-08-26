
# Colors

Three files, split by what changes:

| File | Contains |
|---|---|
| `custom_colors.dart` | brand palette that is the same in light and dark |
| `custom_gradient_colors.dart` | reusable gradients |
| `dynamic_colors.dart` | colors that differ per brightness |

## Usage/Examples

Static brand colors ...
```dart
import 'package:flutter_core/core/utils/colors/custom_colors.dart';

Container(color: CustomColors.primary);
```

Gradients ...
```dart
import 'package:flutter_core/core/utils/colors/custom_gradient_colors.dart';

DecoratedBox(
  decoration: BoxDecoration(gradient: CustomGradientColors.primary),
  child: child,
);
```

Brightness-dependent colors ...
```dart
import 'package:flutter_core/core/utils/colors/dynamic_colors.dart';

Text(
  'hello',
  style: TextStyle(color: DynamicColors.of(context, DynamicColorsName.text)),
);
```

`DynamicColors.of` reads the brightness from `Theme.of(context)`, so the value
stays correct when the theme is `ThemeMode.system` or the user flips the system
theme while the app is running.

Outside a widget (in `theme.dart`, for example) pass the brightness explicitly:

```dart
DynamicColors.get(DynamicColorsName.background, brightness: Brightness.dark);
```

## Adding a color

Add the name to `DynamicColorsName` and a light/dark pair to the
`_dynamicColors` map in the same commit — the lookup asserts the entry exists,
so a missing pair fails loudly instead of returning `null`.
