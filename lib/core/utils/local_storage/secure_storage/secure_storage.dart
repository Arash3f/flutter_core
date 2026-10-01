import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keychain / Keystore backed storage. Use it for tokens and credentials only;
/// every call crosses a platform channel, so it is far slower than
/// `SharedPrefs`.
class SecureStorage {
  const SecureStorage([FlutterSecureStorage? secureStorage])
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  Future<String?> read({required String key}) => _secureStorage.read(key: key);

  Future<void> write({required String key, required String value}) =>
      _secureStorage.write(key: key, value: value);

  Future<void> delete({required String key}) => _secureStorage.delete(key: key);

  Future<bool> containsKey({required String key}) =>
      _secureStorage.containsKey(key: key);

  Future<void> clear() => _secureStorage.deleteAll();

  /// ! My Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenType = 'token_type';
}
