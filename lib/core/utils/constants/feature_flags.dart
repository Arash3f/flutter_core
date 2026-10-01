/// Compile-time switches, set with `--dart-define`.
///
/// ```shell
/// # run the app without a backend: no login, no token refresh
/// flutter run --dart-define=AUTH_ENABLED=false
/// ```
///
/// `bool.fromEnvironment` is resolved at compile time, so a disabled branch is
/// tree-shaken out of release builds.
abstract final class FeatureFlags {
  /// When `false` the router never redirects to login, the splash does not
  /// wait for a session and the shell hides the logout actions.
  static const bool authEnabled = bool.fromEnvironment(
    'AUTH_ENABLED',
    defaultValue: true,
  );
}
