# Colors

Brand tokens from the Arash Alfooneh **Ribbon A** kit (`assets/brand/`).

| Token | Hex | Dart |
| --- | --- | --- |
| Signal Blue | `#016DF1` | `CustomColors.primary` |
| Bright Blue | `#2F8BFF` | `CustomColors.secondary` |
| Ink | `#08090D` | `CustomColors.ink` |
| Paper | `#F5F7FA` | `CustomColors.paper` |
| Muted | `#9AA4B2` | `CustomColors.muted` |
| Line | `#111C2D` | `CustomColors.line` |

Three files, split by what changes:

| File | Contains |
|---|---|
| `custom_colors.dart` | brand palette that is the same in light and dark |
| `custom_gradient_colors.dart` | reusable gradients |
| `dynamic_colors.dart` | colors that differ per brightness (Paper / Ink surfaces) |

## Usage

```dart
Container(color: CustomColors.primary);

Text(
  'hello',
  style: TextStyle(color: DynamicColors.of(context, DynamicColorsName.text)),
);
```

Outside a widget pass brightness explicitly:

```dart
DynamicColors.get(DynamicColorsName.background, brightness: Brightness.dark);
```

## Adding a color

Add the name to `DynamicColorsName` and a light/dark pair to `_dynamicColors`
in the same commit — the lookup asserts the entry exists.
