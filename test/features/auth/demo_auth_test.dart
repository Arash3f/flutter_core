import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_core/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_core/features/auth/data/demo_auth.dart';
import 'package:flutter_core/features/auth/data/models/auth_tokens_model.dart';
import 'package:flutter_core/features/auth/data/models/auth_user_model.dart';
import 'package:flutter_core/features/auth/data/models/user_session_model.dart';
import 'package:flutter_core/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryLocal implements AuthLocalDataSource {
  AuthTokensModel? tokens;

  @override
  Future<void> clear() async => tokens = null;

  @override
  Future<String?> readAccessToken() async => tokens?.accessToken;

  @override
  Future<String?> readRefreshToken() async => tokens?.refreshToken;

  @override
  Future<void> saveTokens(AuthTokensModel value) async => tokens = value;
}

class _TrackingRemote implements AuthRemoteDataSource {
  var loginCalls = 0;

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => throw const UnexpectedFailure();

  @override
  Future<AuthTokensModel> login({
    required String username,
    required String password,
  }) async {
    loginCalls++;
    throw const AuthFailure();
  }

  @override
  Future<void> logout() => throw const UnexpectedFailure();

  @override
  Future<void> logoutAll() => throw const UnexpectedFailure();

  @override
  Future<AuthUserModel> me() => throw const UnexpectedFailure();

  @override
  Future<AuthTokensModel> refresh(String refreshToken) =>
      throw const UnexpectedFailure();

  @override
  Future<void> revokeSession(String sessionId) =>
      throw const UnexpectedFailure();

  @override
  Future<List<UserSessionModel>> sessions() => throw const UnexpectedFailure();
}

void main() {
  test('admin/admin logs in offline without calling the remote', () async {
    final local = _MemoryLocal();
    final remote = _TrackingRemote();
    final repository = AuthRepositoryImpl(remote: remote, local: local);

    await repository.login(username: 'admin', password: 'admin');

    expect(remote.loginCalls, 0);
    expect(local.tokens?.accessToken, DemoAuth.accessToken);
    expect(await repository.getCurrentUser(), DemoAuth.user);
    expect(await repository.refreshSession(), isTrue);
  });

  test('non-demo credentials still hit the remote', () async {
    final remote = _TrackingRemote();
    final repository = AuthRepositoryImpl(
      remote: remote,
      local: _MemoryLocal(),
    );

    await expectLater(
      repository.login(username: 'admin', password: 'nope'),
      throwsA(const AuthFailure()),
    );
    expect(remote.loginCalls, 1);
  });
}
