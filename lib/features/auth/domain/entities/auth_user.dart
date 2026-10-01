import 'package:equatable/equatable.dart';

/// The signed-in user, as the rest of the app sees it.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.username,
    this.fullname = '',
    this.roleId,
    this.roleName,
    this.permissions = const [],
    this.lastSessionAt,
  });

  final String id;
  final String username;
  final String fullname;
  final String? roleId;
  final String? roleName;

  /// Permission names granted to the user's role, e.g. `user_read`. Compare
  /// against constants you define per project; never hard-code strings in
  /// widgets.
  final List<String> permissions;
  final DateTime? lastSessionAt;

  /// [fullname] when the backend has one, otherwise [username].
  String get displayName => fullname.trim().isEmpty ? username : fullname;

  bool hasPermission(String permission) => permissions.contains(permission);

  @override
  List<Object?> get props => [
    id,
    username,
    fullname,
    roleId,
    roleName,
    permissions,
    lastSessionAt,
  ];
}
