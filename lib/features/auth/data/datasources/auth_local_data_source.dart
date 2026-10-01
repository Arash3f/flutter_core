import 'package:flutter_core/core/utils/local_storage/helper_functions.dart';
import 'package:flutter_core/features/auth/data/models/auth_tokens_model.dart';

/// Token persistence. The only auth file that knows where tokens live; the
/// network clients read the access token through `AppStorageHelper` too, so
/// both must agree on the same keys.
abstract interface class AuthLocalDataSource {
  Future<String?> readAccessToken();

  Future<String?> readRefreshToken();

  Future<void> saveTokens(AuthTokensModel tokens);

  Future<void> clear();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl();

  @override
  Future<String?> readAccessToken() => AppStorageHelper.getAccessToken();

  @override
  Future<String?> readRefreshToken() => AppStorageHelper.getRefreshToken();

  @override
  Future<void> saveTokens(AuthTokensModel tokens) => AppStorageHelper.setTokens(
    accessToken: tokens.accessToken,
    refreshToken: tokens.refreshToken,
    tokenType: tokens.tokenType,
  );

  @override
  Future<void> clear() => AppStorageHelper.clearTokens();
}
