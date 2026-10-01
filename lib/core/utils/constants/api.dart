import 'package:flutter/foundation.dart';

/// Endpoint and API constants.
///
/// Secrets do not belong here - this file is committed. Pass overrides at build
/// time instead and read them with `String.fromEnvironment`:
///
/// ```shell
/// flutter run --dart-define=API_BASE_URL=https://api.example.com
/// ```
///
/// Without `API_BASE_URL`, debug builds talk to [_localUrl] and release builds
/// to [_productionUrl]. Edit both constants when a project starts.
///
/// `127.0.0.1` is the device itself. From the Android emulator use
/// `http://10.0.2.2:<port>`; from a USB phone run
/// `adb reverse tcp:8000 tcp:8000` so `127.0.0.1` reaches your machine.
class ApiConfig {
  const ApiConfig._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String _productionUrl = 'https://api.example.com';
  static const String _localUrl = 'http://127.0.0.1:8000';

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kDebugMode) return _localUrl;
    return _productionUrl;
  }

  static const String graphqlPath = String.fromEnvironment(
    'GRAPHQL_PATH',
    defaultValue: '/graphql',
  );

  static String get graphqlUrl => '$baseUrl$graphqlPath';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
