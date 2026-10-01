import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/network/api_error_mapper.dart';
import 'package:flutter_core/core/utils/logging/logger.dart';
import 'package:flutter_core/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_core/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_core/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_core/features/auth/domain/entities/user_session.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this._remote, required this._local});

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<void> login({required String username, required String password}) =>
      _guard(() async {
        final tokens = await _remote.login(
          username: username,
          password: password,
        );
        await _local.saveTokens(tokens);
      });

  @override
  Future<bool> hasSession() async {
    final token = await _local.readAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<bool> refreshSession() async {
    final refreshToken = await _local.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;
    try {
      await _local.saveTokens(await _remote.refresh(refreshToken));
      return true;
    } on Object catch (error) {
      LoggerService.warning('Token refresh failed: $error');
      return false;
    }
  }

  @override
  Future<void> logout() => _endSession(_remote.logout);

  @override
  Future<void> logoutAll() => _endSession(_remote.logoutAll);

  @override
  Future<void> clearSession() => _local.clear();

  @override
  Future<AuthUser> getCurrentUser() => _guard(_remote.me);

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _guard(
    () => _remote.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    ),
  );

  @override
  Future<List<UserSession>> getSessions() => _guard(_remote.sessions);

  @override
  Future<void> revokeSession(String sessionId) =>
      _guard(() => _remote.revokeSession(sessionId));

  /// The server call is best effort: being offline or already expired must
  /// never keep the user signed in on this device.
  Future<void> _endSession(Future<void> Function() remoteCall) async {
    try {
      await remoteCall();
    } on Object catch (error) {
      LoggerService.warning('Remote logout failed, clearing locally: $error');
    }
    await _local.clear();
  }

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on Failure {
      rethrow;
    } on Object catch (error, stackTrace) {
      LoggerService.error('AuthRepository failure', error, stackTrace);
      ApiErrorMapper.mapAndThrow(error);
    }
  }
}
