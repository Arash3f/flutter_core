import 'package:flutter_core/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_core/features/auth/domain/entities/user_session.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

/// In-memory [AuthRepository] for use-case tests. Set [currentUserError] to
/// make [getCurrentUser] fail.
class FakeAuthRepository implements AuthRepository {
  bool hasToken = false;
  bool cleared = false;
  Object? currentUserError;
  AuthUser user = const AuthUser(id: '1', username: 'admin');
  final List<(String, String)> passwordChanges = [];

  @override
  Future<bool> hasSession() async => hasToken;

  @override
  Future<AuthUser> getCurrentUser() async {
    final error = currentUserError;
    if (error != null) throw error;
    return user;
  }

  @override
  Future<void> clearSession() async {
    cleared = true;
    hasToken = false;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    passwordChanges.add((currentPassword, newPassword));
  }

  @override
  Future<void> login({
    required String username,
    required String password,
  }) async {
    hasToken = true;
  }

  @override
  Future<void> logout() => clearSession();

  @override
  Future<void> logoutAll() => clearSession();

  @override
  Future<bool> refreshSession() async => hasToken;

  @override
  Future<List<UserSession>> getSessions() async => const [];

  @override
  Future<void> revokeSession(String sessionId) async {}
}
