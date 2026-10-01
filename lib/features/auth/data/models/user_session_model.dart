import 'package:flutter_core/core/utils/json/json_reader.dart';
import 'package:flutter_core/features/auth/domain/entities/user_session.dart';

class UserSessionModel extends UserSession {
  const UserSessionModel({
    required super.id,
    super.userAgent,
    super.ipAddress,
    super.createdAt,
    super.expiresAt,
    super.isCurrent,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    final r = JsonReader(json);
    return UserSessionModel(
      id: r.string('id', 'session_id') ?? '',
      userAgent: r.string('user_agent', 'userAgent'),
      ipAddress: r.string('ip_address', 'ipAddress'),
      createdAt: r.date('created_at', 'createdAt'),
      expiresAt: r.date('expires_at', 'expiresAt'),
      isCurrent: r.boolean('is_current', 'isCurrent'),
    );
  }

  static List<UserSessionModel> listFromJson(Object? data) {
    if (data is! List) return const [];
    return data
        .whereType<Map<dynamic, dynamic>>()
        .map((row) => UserSessionModel.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }
}
