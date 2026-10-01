import 'package:equatable/equatable.dart';

/// One signed-in device / refresh token of the current user.
class UserSession extends Equatable {
  const UserSession({
    required this.id,
    this.userAgent,
    this.ipAddress,
    this.createdAt,
    this.expiresAt,
    this.isCurrent = false,
  });

  final String id;
  final String? userAgent;
  final String? ipAddress;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  /// The session this device is using. Revoking it is the same as logging
  /// out, so the UI hides the revoke action for it.
  final bool isCurrent;

  @override
  List<Object?> get props => [
    id,
    userAgent,
    ipAddress,
    createdAt,
    expiresAt,
    isCurrent,
  ];
}
