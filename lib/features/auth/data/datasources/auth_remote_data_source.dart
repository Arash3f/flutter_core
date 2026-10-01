import 'package:dio/dio.dart';
import 'package:flutter_core/core/network/rest/rest_client.dart';
import 'package:flutter_core/features/auth/data/models/auth_tokens_model.dart';
import 'package:flutter_core/features/auth/data/models/auth_user_model.dart';
import 'package:flutter_core/features/auth/data/models/user_session_model.dart';

/// Talks to the auth backend. Two implementations ship:
///
/// - [AuthRestDataSource] (default) - JSON over HTTP, paths in [AuthEndpoints]
/// - `AuthGraphQLDataSource` - the same operations as GraphQL documents
///
/// Pick one in `authRemoteDataSourceProvider`. Both throw domain `Failure`s.
abstract interface class AuthRemoteDataSource {
  Future<AuthTokensModel> login({
    required String username,
    required String password,
  });

  Future<AuthTokensModel> refresh(String refreshToken);

  Future<void> logout();

  Future<void> logoutAll();

  Future<AuthUserModel> me();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<List<UserSessionModel>> sessions();

  Future<void> revokeSession(String sessionId);
}

/// REST contract. Adjust paths and body keys to your backend.
abstract final class AuthEndpoints {
  /// `{username, password}` -> `{access_token, refresh_token, token_type}`
  static const String login = '/auth/login';

  /// `{refresh_token}` -> same shape as [login]
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String logoutAll = '/auth/logout-all';

  /// -> `{id, username, fullname, role_id, role_name, permissions: [..]}`
  static const String me = '/auth/me';

  /// `{current_password, new_password}`
  static const String password = '/auth/password';

  /// -> `[{id, user_agent, ip_address, created_at, expires_at, is_current}]`
  static const String sessions = '/auth/sessions';
  static String session(String id) => '/auth/sessions/$id';
}

class AuthRestDataSource implements AuthRemoteDataSource {
  const AuthRestDataSource(this._client);

  final RestClient _client;

  static final Options _public = Options(extra: {RestClient.skipAuth: true});

  @override
  Future<AuthTokensModel> login({
    required String username,
    required String password,
  }) => _client.send((dio) async {
    final response = await dio.post<Map<String, dynamic>>(
      AuthEndpoints.login,
      data: {'username': username, 'password': password},
      options: _public,
    );
    return AuthTokensModel.fromJson(response.data ?? const {});
  });

  @override
  Future<AuthTokensModel> refresh(String refreshToken) =>
      _client.send((dio) async {
        final response = await dio.post<Map<String, dynamic>>(
          AuthEndpoints.refresh,
          data: {'refresh_token': refreshToken},
          options: _public,
        );
        return AuthTokensModel.fromJson(response.data ?? const {});
      });

  @override
  Future<void> logout() =>
      _client.send((dio) => dio.post<void>(AuthEndpoints.logout));

  @override
  Future<void> logoutAll() =>
      _client.send((dio) => dio.post<void>(AuthEndpoints.logoutAll));

  @override
  Future<AuthUserModel> me() => _client.send((dio) async {
    final response = await dio.get<Map<String, dynamic>>(AuthEndpoints.me);
    return AuthUserModel.fromJson(response.data ?? const {});
  });

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _client.send(
    (dio) => dio.put<void>(
      AuthEndpoints.password,
      data: {'current_password': currentPassword, 'new_password': newPassword},
    ),
  );

  @override
  Future<List<UserSessionModel>> sessions() => _client.send((dio) async {
    final response = await dio.get<Object?>(AuthEndpoints.sessions);
    return UserSessionModel.listFromJson(response.data);
  });

  @override
  Future<void> revokeSession(String sessionId) =>
      _client.send((dio) => dio.delete<void>(AuthEndpoints.session(sessionId)));
}
