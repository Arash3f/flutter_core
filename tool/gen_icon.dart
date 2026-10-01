import 'dart:io';

import 'package:image/image.dart';

/// Builds launcher icons from the Arash Alfooneh brand mark in `assets/brand/`.
///
/// Brand primary form: Signal Blue ribbon on Ink. Using a blue mark on a blue
/// adaptive background makes the logo invisible on Android — do not do that.
///
/// ```shell
/// dart run tool/gen_icon.dart
/// dart run flutter_launcher_icons
/// ```
void main() {
  final markBlue = _read('assets/brand/mark-blue.png');
  final markWhite = _read('assets/brand/mark-white.png');

  const size = 1024;
  final ink = ColorRgba8(0x08, 0x09, 0x0D, 255);
  final signalBlue = ColorRgba8(0x01, 0x6D, 0xF1, 255);

  // Store / iOS / legacy: Ink tile + blue ribbon (primary brand form).
  final icon = Image(width: size, height: size, numChannels: 4);
  fill(icon, color: ink);
  _pasteCentered(icon, markBlue, scale: 0.7);
  _write('assets/icons/app_icon.png', icon);

  // Android adaptive foreground must contrast with [adaptive_icon_background].
  // Background is Ink → blue mark. (A blue mark on Signal Blue is invisible.)
  final foreground = Image(width: size, height: size, numChannels: 4);
  _pasteCentered(foreground, markBlue, scale: 0.62);
  _write('assets/icons/app_icon_foreground.png', foreground);

  // Optional blue-tile variant kept for places that want Signal Blue chrome.
  final blueTile = Image(width: size, height: size, numChannels: 4);
  fill(blueTile, color: signalBlue);
  _pasteCentered(blueTile, markWhite, scale: 0.7);
  _write('assets/icons/app_icon_blue.png', blueTile);

  stdout.writeln('icons written to assets/icons/ (Ink + blue mark)');
}

Image _read(String path) {
  final bytes = File(path).readAsBytesSync();
  final image = decodePng(bytes);
  if (image == null) {
    throw StateError('Could not decode $path');
  }
  return image;
}

void _pasteCentered(Image canvas, Image source, {required double scale}) {
  final target = (canvas.width * scale).round();
  final resized = copyResize(
    source,
    width: target,
    height: target,
    interpolation: Interpolation.cubic,
  );
  final ox = ((canvas.width - resized.width) / 2).round();
  final oy = ((canvas.height - resized.height) / 2).round();
  compositeImage(canvas, resized, dstX: ox, dstY: oy);
}

void _write(String path, Image image) {
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(encodePng(image));
}
