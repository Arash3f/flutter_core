import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

/// Brands the first Flutter frames after the native splash is removed.
///
/// Does not own navigation — [SplashGate] swaps this out when bootstrap
/// finishes.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: CustomColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: TSizes.md,
          children: [
            Icon(
              Icons.layers_rounded,
              size: TSizes.iconLg * 2,
              color: CustomColors.white,
            ),
            Text(
              'Flutter Core',
              style: TextStyle(
                color: CustomColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows [SplashScreen] until the app is ready, then reveals [child].
///
/// SharedPreferences and localization are already initialized in `main`
/// before the first frame; this gate covers a short branding window and any
/// future async warm-ups without a router.
class SplashGate extends StatefulWidget {
  const SplashGate({required this.child, super.key});

  final Widget child;

  /// Minimum time the Flutter splash stays visible after native splash.
  static const Duration minDisplay = Duration(milliseconds: 900);

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Native splash can go away as soon as Flutter paints this screen.
    FlutterNativeSplash.remove();

    await Future<void>.delayed(SplashGate.minDisplay);

    if (!mounted) return;

    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SplashScreen();
    return widget.child;
  }
}
