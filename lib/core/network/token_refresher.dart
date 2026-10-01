/// Late-bound, single-flight access-token refresh shared by every client.
///
/// The network layer needs to refresh tokens, but the refresh logic lives in
/// the auth feature, which itself depends on the network layer. Binding the
/// handler at runtime breaks that cycle: the clients only know this object,
/// and the auth feature calls [bind] once its repository exists.
///
/// Concurrent callers share one in-flight refresh. Backends that rotate
/// refresh tokens invalidate the old one on first use, so two parallel
/// refreshes would log the user out.
class TokenRefresher {
  Future<bool> Function()? _handler;
  Future<bool>? _inFlight;

  bool get isBound => _handler != null;

  /// [handler] returns `true` when new tokens were stored.
  void bind(Future<bool> Function() handler) => _handler = handler;

  void unbind() => _handler = null;

  /// Returns `false` when nothing is bound or the refresh failed; never throws.
  Future<bool> call() {
    final existing = _inFlight;
    if (existing != null) return existing;

    final handler = _handler;
    if (handler == null) return Future.value(false);

    final future = _run(handler).whenComplete(() => _inFlight = null);
    _inFlight = future;
    return future;
  }

  static Future<bool> _run(Future<bool> Function() handler) async {
    try {
      return await handler();
    } on Object {
      return false;
    }
  }
}
