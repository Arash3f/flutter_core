/// Endpoint and API constants.
///
/// Secrets do not belong here — this file is committed. Pass them at build
/// time instead and read them with `String.fromEnvironment`:
///
/// ```shell
/// flutter run --dart-define=API_ACCESS_TOKEN=xxx
/// ```
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const String accessToken = String.fromEnvironment(
    'API_ACCESS_TOKEN',
    defaultValue: '',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
