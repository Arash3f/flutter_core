import 'package:flutter_core/core/utils/device/breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ofWidth follows the Material 3 window-size classes', () {
    expect(Breakpoints.ofWidth(390), AppBreakpoint.compact);
    expect(Breakpoints.ofWidth(600), AppBreakpoint.medium);
    expect(Breakpoints.ofWidth(839), AppBreakpoint.medium);
    expect(Breakpoints.ofWidth(840), AppBreakpoint.expanded);
    expect(Breakpoints.ofWidth(1200), AppBreakpoint.large);
  });

  test('navigation switches from bar to rail at 840dp', () {
    expect(Breakpoints.useBottomNav(839), isTrue);
    expect(Breakpoints.useBottomNav(840), isFalse);
    expect(Breakpoints.useExtendedRail(1199), isFalse);
    expect(Breakpoints.useExtendedRail(1200), isTrue);
  });
}
