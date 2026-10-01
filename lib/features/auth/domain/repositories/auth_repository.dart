import 'package:flutter_core/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_core/features/auth/domain/entities/user_session.dart';

/// Authentication and account operations.
///
/// Tokens never cross this boundary: the implementation stores and reads
/// them itself, so the domain only deals in "is there a session" and users.
///
/// Throws a `Failure` on error; `AuthFailure` means the session is gone.
abstract interface class AuthRepository {
  /// Signs in and persists the tokens.
  Future<void> login({required String username, required String password});

  /// Whether an access token is stored. Says nothing about its validity.
  Future<bool> hasSession();

  /// Exchanges the stored refresh token for a new pair. Returns `false` when
  /// there is no refresh token or the server rejected it.
  Future<bool> refreshSession();

  /// Revokes this device's session server-side (best effort) and always
  /// clears the local tokens.
  Future<void> logout();

  /// Like [logout], but revokes every session of the user.
  Future<void> logoutAll();

  /// Drops the local tokens without calling the server.
  Future<void> clearSession();

  Future<AuthUser> getCurrentUser();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<List<UserSession>> getSessions();

  Future<void> revokeSession(String sessionId);
}
