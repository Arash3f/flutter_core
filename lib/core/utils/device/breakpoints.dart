enum AppBreakpoint { compact, medium, expanded, large }

/// Window-size classes from the Material 3 layout guidance.
///
/// Decide layout on the *window* width (`MediaQuery.sizeOf(context).width`),
/// not on the platform: a phone in landscape, a tablet in split screen and a
/// narrow desktop window should all get the layout that fits.
abstract final class Breakpoints {
  static const double compactMax = 600;
  static const double mediumMax = 840;
  static const double expandedMax = 1200;

  static AppBreakpoint ofWidth(double width) {
    if (width < compactMax) return AppBreakpoint.compact;
    if (width < mediumMax) return AppBreakpoint.medium;
    if (width < expandedMax) return AppBreakpoint.expanded;
    return AppBreakpoint.large;
  }

  /// Bottom `NavigationBar` below this, `NavigationRail` above.
  static bool useBottomNav(double width) => width < mediumMax;

  /// Rail shows labels next to icons on wide windows.
  static bool useExtendedRail(double width) => width >= expandedMax;
}
