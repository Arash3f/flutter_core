import 'package:flutter_core/features/auth/data/models/auth_tokens_model.dart';
import 'package:flutter_core/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_core/features/auth/domain/entities/user_session.dart';

/// Offline demo account for trying the UI without a backend.
///
/// Login with [username] / [password] stores fake tokens locally and never
/// hits the network. Remove or change these before shipping a real product.
abstract final class DemoAuth {
  static const String username = 'admin';
  static const String password = 'admin';

  static const String accessToken = 'demo.access.token';
  static const String refreshToken = 'demo.refresh.token';

  static bool matchesCredentials(String username, String password) =>
      username.trim() == DemoAuth.username && password == DemoAuth.password;

  static bool isDemoToken(String? token) =>
      token == accessToken || token == refreshToken;

  static const AuthTokensModel tokens = AuthTokensModel(
    accessToken: accessToken,
    refreshToken: refreshToken,
    tokenType: 'bearer',
  );

  static final AuthUser user = AuthUser(
    id: 'demo-admin',
    username: username,
    fullname: 'Demo Admin',
    roleName: 'Admin',
    permissions: const [
      'user_read',
      'user_create',
      'user_update',
      'user_delete',
    ],
    lastSessionAt: DateTime.utc(2026, 1, 1),
  );

  static List<UserSession> sessions() => [
        UserSession(
          id: 'demo-session',
          userAgent: 'Flutter Core (demo)',
          ipAddress: '127.0.0.1',
          createdAt: DateTime.now().toUtc(),
          isCurrent: true,
        ),
      ];
}
