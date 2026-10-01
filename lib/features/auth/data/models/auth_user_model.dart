import 'package:flutter_core/core/utils/json/json_reader.dart';
import 'package:flutter_core/features/auth/domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.username,
    super.fullname,
    super.roleId,
    super.roleName,
    super.permissions,
    super.lastSessionAt,
  });

  /// Accepts both `snake_case` (typical REST) and `camelCase` (typical
  /// GraphQL) keys, so either data source can use it.
  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final r = JsonReader(json);
    return AuthUserModel(
      id: r.string('id', 'user_id') ?? '',
      username: r.string('username') ?? '',
      fullname: r.string('fullname', 'full_name', 'fullName') ?? '',
      roleId: r.string('role_id', 'roleId'),
      roleName: r.string('role_name', 'roleName'),
      permissions: r.strings('permissions'),
      lastSessionAt: r.date('last_session_at', 'lastSessionAt'),
    );
  }
}
