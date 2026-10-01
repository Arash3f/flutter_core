// Generates the placeholder launcher icon from code, so a new project has a
// valid icon without a designer and without binary files of unknown origin.
//
// Run from the project root:
//
//   dart run tool/gen_icon.dart
//   dart run flutter_launcher_icons
//
// Replace the two PNGs with real artwork whenever it exists; nothing else
// depends on this script.
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart';

const int _size = 1024;

/// `CustomColors.primary` (#2563EB). Keep in sync with
/// `flutter_launcher_icons.adaptive_icon_background` in `pubspec.yaml`.
final ColorRgba8 _brand = ColorRgba8(0x25, 0x63, 0xEB, 255);

void main() {
  final icon = Image(width: _size, height: _size, numChannels: 4);
  fill(icon, color: _brand);
  _drawMark(icon, scale: 1);
  _write('assets/icons/app_icon.png', icon);

  // Android adaptive icons crop to the inner ~66%, so the foreground mark is
  // drawn smaller on a transparent canvas.
  final foreground = Image(width: _size, height: _size, numChannels: 4);
  _drawMark(foreground, scale: 0.66);
  _write('assets/icons/app_icon_foreground.png', foreground);

  stdout.writeln('icons written to assets/icons/');
}

/// Three stacked rhombi, the same idea as `AppMark` (`Icons.layers_rounded`).
void _drawMark(Image image, {required double scale}) {
  const center = _size / 2;
  final halfWidth = 300 * scale;
  final halfHeight = 150 * scale;
  final step = 110 * scale;

  final outline = math.max(1, (16 * scale).round());

  // Back to front; tints are opaque so the layers occlude each other.
  for (final (offset, tint) in [(step, 0.55), (0.0, 0.78), (-step, 1.0)]) {
    final cy = center + offset;
    final corners = [
      (x: center, y: cy - halfHeight),
      (x: center + halfWidth, y: cy),
      (x: center, y: cy + halfHeight),
      (x: center - halfWidth, y: cy),
    ];
    fillPolygon(
      image,
      vertices: [for (final c in corners) Point(c.x, c.y)],
      color: _whiteOverBrand(tint),
    );
    // A brand-colored edge separates a layer from the one below it.
    for (var i = 0; i < corners.length; i++) {
      final a = corners[i];
      final b = corners[(i + 1) % corners.length];
      drawLine(
        image,
        x1: a.x.round(),
        y1: a.y.round(),
        x2: b.x.round(),
        y2: b.y.round(),
        color: _brand,
        thickness: outline,
        antialias: true,
      );
    }
  }
}

ColorRgba8 _whiteOverBrand(double amount) {
  int mix(num channel) => (channel + (255 - channel) * amount).round();
  return ColorRgba8(mix(_brand.r), mix(_brand.g), mix(_brand.b), 255);
}

void _write(String path, Image image) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(encodePng(image));
}
