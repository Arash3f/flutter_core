import 'package:flutter_core/core/network/api_error_mapper.dart';
import 'package:flutter_core/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_core/features/auth/data/models/auth_tokens_model.dart';
import 'package:flutter_core/features/auth/data/models/auth_user_model.dart';
import 'package:flutter_core/features/auth/data/models/user_session_model.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// GraphQL flavor of [AuthRemoteDataSource].
///
/// The documents below are the contract - rename fields to match your schema.
/// Operation names `Login` and `RefreshToken` must stay in sync with
/// `RefreshLink.skipOperations`, otherwise a wrong password would trigger a
/// token refresh.
class AuthGraphQLDataSource implements AuthRemoteDataSource {
  const AuthGraphQLDataSource(this._client);

  final GraphQLClient _client;

  @override
  Future<AuthTokensModel> login({
    required String username,
    required String password,
  }) async {
    final data = await _mutate(_loginMutation, {
      'username': username,
      'password': password,
    });
    return AuthTokensModel.fromJson(_field(data, 'login'));
  }

  @override
  Future<AuthTokensModel> refresh(String refreshToken) async {
    final data = await _mutate(_refreshMutation, {
      'refreshToken': refreshToken,
    });
    return AuthTokensModel.fromJson(_field(data, 'refreshToken'));
  }

  @override
  Future<void> logout() => _mutate(_logoutMutation);

  @override
  Future<void> logoutAll() => _mutate(_logoutAllMutation);

  @override
  Future<AuthUserModel> me() async {
    final data = await _query(_meQuery);
    return AuthUserModel.fromJson(_field(data, 'me'));
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _mutate(_changePasswordMutation, {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  });

  @override
  Future<List<UserSessionModel>> sessions() async {
    final data = await _query(_sessionsQuery);
    return UserSessionModel.listFromJson(data['mySessions']);
  }

  @override
  Future<void> revokeSession(String sessionId) =>
      _mutate(_revokeSessionMutation, {'id': sessionId});

  Future<Map<String, dynamic>> _query(String document) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(document),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    return _unwrap(result);
  }

  Future<Map<String, dynamic>> _mutate(
    String document, [
    Map<String, dynamic> variables = const {},
  ]) async {
    final result = await _client.mutate(
      MutationOptions(document: gql(document), variables: variables),
    );
    return _unwrap(result);
  }

  static Map<String, dynamic> _unwrap(QueryResult result) {
    final exception = result.exception;
    if (exception != null) throw ApiErrorMapper.fromGraphQL(exception);
    return result.data ?? const {};
  }

  static Map<String, dynamic> _field(Map<String, dynamic> data, String key) {
    final value = data[key];
    if (value is! Map) throw FormatException('Response is missing "$key".');
    return Map<String, dynamic>.from(value);
  }
}

const String _loginMutation = r'''
mutation Login($username: String!, $password: String!) {
  login(username: $username, password: $password) {
    accessToken
    refreshToken
    tokenType
  }
}
''';

const String _refreshMutation = r'''
mutation RefreshToken($refreshToken: String!) {
  refreshToken(refreshToken: $refreshToken) {
    accessToken
    refreshToken
    tokenType
  }
}
''';

const String _logoutMutation = r'''
mutation Logout {
  logout { result }
}
''';

const String _logoutAllMutation = r'''
mutation LogoutAll {
  logoutAll { result }
}
''';

const String _meQuery = r'''
query Me {
  me {
    id
    username
    fullname
    roleId
    roleName
    permissions
    lastSessionAt
  }
}
''';

const String _changePasswordMutation = r'''
mutation ChangePassword($currentPassword: String!, $newPassword: String!) {
  changePassword(currentPassword: $currentPassword, newPassword: $newPassword) {
    result
  }
}
''';

const String _sessionsQuery = r'''
query MySessions {
  mySessions {
    id
    userAgent
    ipAddress
    createdAt
    expiresAt
    isCurrent
  }
}
''';

const String _revokeSessionMutation = r'''
mutation RevokeSession($id: ID!) {
  revokeSession(id: $id) { result }
}
''';
