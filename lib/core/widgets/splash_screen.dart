import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/utils/colors/custom_colors.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';

/// Animated branded splash shown after the native splash is removed.
///
/// Matches the native splash color (`flutter_native_splash` in
/// `pubspec.yaml`), so the hand-off is seamless. Honors the platform's
/// "reduce motion" setting by jumping straight to the final frame.
///
/// Does not own navigation - `SplashGate` swaps it out when bootstrap ends.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  bool _motionChecked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_motionChecked) return;
    _motionChecked = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
      _pulse
        ..stop()
        ..value = 0.5;
    }
  }

  @override
  void dispose() {
    _intro.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Brand primary form: Signal Blue on light, Ink + blue mark on dark.
    final base = isDark ? CustomColors.ink : CustomColors.primary;
    final ink = isDark ? CustomColors.primary : CustomColors.white;
    final markAsset = isDark
        ? 'assets/brand/mark-blue.png'
        : 'assets/brand/mark-white.png';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: base,
      ),
      child: Scaffold(
        backgroundColor: base,
        body: AnimatedBuilder(
          animation: Listenable.merge([_intro, _pulse]),
          builder: (context, _) {
            final intro = _intro.value;
            final pulse = _pulse.value;
            return Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.25),
                      radius: 0.9,
                      colors: [
                        ink.withValues(alpha: 0.10 + pulse * 0.06),
                        ink.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Column(
                    children: [
                      const Spacer(flex: 5),
                      _Emblem(
                        intro: intro,
                        pulse: pulse,
                        ink: ink,
                        markAsset: markAsset,
                      ),
                      const SizedBox(height: 32),
                      _BrandCopy(intro: intro, ink: ink),
                      const Spacer(flex: 4),
                      Opacity(
                        opacity: _span(intro, 0.6, 1),
                        child: _DotsLoader(t: pulse, color: ink),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({
    required this.intro,
    required this.pulse,
    required this.ink,
    required this.markAsset,
  });

  final double intro;
  final double pulse;
  final Color ink;
  final String markAsset;

  @override
  Widget build(BuildContext context) {
    final appear = _span(intro, 0, 0.45);
    return Opacity(
      opacity: appear,
      child: Transform.scale(
        scale: 0.85 + appear * 0.15,
        child: SizedBox.square(
          dimension: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              _Ring(
                size: 180,
                scale: 0.92 + pulse * 0.08,
                color: ink,
                alpha: 0.14,
              ),
              _Ring(
                size: 150,
                scale: 1 - pulse * 0.05,
                color: ink,
                alpha: 0.22,
              ),
              Transform.scale(
                scale: 1 + pulse * 0.03,
                child: Image.asset(
                  markAsset,
                  width: 112,
                  height: 112,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({
    required this.size,
    required this.scale,
    required this.color,
    required this.alpha,
  });

  final double size;
  final double scale;
  final Color color;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color.withValues(alpha: alpha)),
        ),
      ),
    );
  }
}

class _BrandCopy extends StatelessWidget {
  const _BrandCopy({required this.intro, required this.ink});

  final double intro;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    final titleT = _span(intro, 0.35, 0.7);
    final tagT = _span(intro, 0.5, 0.85);
    return Column(
      children: [
        Opacity(
          opacity: titleT,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - titleT)),
            child: Text(
              LocaleKeys.brand.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ink,
                fontSize: 30,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Opacity(
          opacity: tagT,
          child: Text(
            LocaleKeys.splashTagline.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ink.withValues(alpha: 0.75),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _DotsLoader extends StatelessWidget {
  const _DotsLoader({required this.t, required this.color});

  final double t;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 10,
      children: [
        for (var i = 0; i < 3; i++)
          Builder(
            builder: (context) {
              final wave = (math.sin(t * math.pi * 2 - i * 1.1) + 1) / 2;
              return Container(
                width: 7 + wave * 2,
                height: 7 + wave * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.35 + wave * 0.65),
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Maps [t] in `[start, end]` to an eased `0..1`, clamped outside the range.
double _span(double t, double start, double end) {
  if (t <= start) return 0;
  if (t >= end) return 1;
  return Curves.easeOutCubic.transform((t - start) / (end - start));
}
