import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/utils/constants/feature_flags.dart';
import 'package:flutter_core/core/widgets/splash_screen.dart';
import 'package:flutter_core/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shows [SplashScreen] until bootstrap finishes, then reveals [child].
///
/// SharedPreferences and localization are initialized in `main` before the
/// first frame. This gate covers the async work that needs providers - today
/// restoring the auth session, so the router's first redirect already knows
/// whether the user is signed in and never flashes the login page.
///
/// Add further warm-ups (remote config, feature flags, ...) to [_bootstrap].
class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({required this.child, super.key});

  final Widget child;

  /// Lower bound so the splash animation does not flash by on fast devices.
  static const Duration minDisplay = Duration(milliseconds: 1200);

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
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

    await Future.wait<void>([
      Future<void>.delayed(SplashGate.minDisplay),
      if (FeatureFlags.authEnabled)
        // Never rejects: the session resolves to anonymous on any error.
        ref
            .read(authSessionProvider.future)
            .then<void>((_) {}, onError: (Object _) {}),
    ]);

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
