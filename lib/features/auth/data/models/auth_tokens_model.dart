import 'package:flutter_core/core/utils/json/json_reader.dart';

/// Token pair returned by login and refresh. Data-layer only: the domain never
/// sees tokens.
class AuthTokensModel {
  const AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'bearer',
  });

  /// Throws [FormatException] when either token is missing, so a malformed
  /// response fails loudly instead of storing the string `"null"`.
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final r = JsonReader(json);
    final access = r.string('access_token', 'accessToken');
    final refresh = r.string('refresh_token', 'refreshToken');
    if (access == null || refresh == null) {
      throw const FormatException('Token response is missing a token.');
    }
    return AuthTokensModel(
      accessToken: access,
      refreshToken: refresh,
      tokenType: r.string('token_type', 'tokenType') ?? 'bearer',
    );
  }

  final String accessToken;
  final String refreshToken;
  final String tokenType;
}
