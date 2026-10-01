/// Every path the app can navigate to, in one place.
///
/// Navigate with `context.go(AppRoutes.settings)`, never with a string
/// literal, so renaming a route is a one-line change.
abstract final class AppRoutes {
  static const String login = '/login';

  // Inside the shell (bottom bar / rail).
  static const String home = '/';
  static const String profile = '/profile';
  static const String settings = '/settings';

  /// Routes reachable without a session. The redirect sends signed-in users
  /// away from these and anonymous users towards [login] from anything else.
  static const Set<String> public = {login};
}
