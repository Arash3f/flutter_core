import 'dart:async';

import 'package:flutter_core/core/network/token_refresher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('returns false when nothing is bound', () async {
    expect(await TokenRefresher().call(), isFalse);
  });

  test('concurrent callers share one in-flight refresh', () async {
    final refresher = TokenRefresher();
    final gate = Completer<bool>();
    var calls = 0;
    refresher.bind(() {
      calls++;
      return gate.future;
    });

    final first = refresher();
    final second = refresher();
    gate.complete(true);

    expect(await Future.wait([first, second]), [true, true]);
    expect(calls, 1);
  });

  test('starts a new refresh once the previous one finished', () async {
    final refresher = TokenRefresher();
    var calls = 0;
    refresher.bind(() async {
      calls++;
      return true;
    });

    await refresher();
    await refresher();

    expect(calls, 2);
  });

  test('a throwing handler yields false instead of an error', () async {
    final refresher = TokenRefresher()
      ..bind(() async => throw StateError('boom'));

    expect(await refresher(), isFalse);
  });

  test('unbind makes refresh a no-op', () async {
    final refresher = TokenRefresher()
      ..bind(() async => true)
      ..unbind();

    expect(refresher.isBound, isFalse);
    expect(await refresher(), isFalse);
  });
}
