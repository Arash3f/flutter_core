/// Raw errors thrown by data sources.
///
/// Data sources speak in exceptions, repositories translate them into
/// `Failure`s via [FailureMapper]. That boundary is what keeps
/// `package:dio`, `sqflite`, and friends out of the domain layer.
class CacheException implements Exception {
  const CacheException([this.message = 'Local storage operation failed.']);

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class ServerException implements Exception {
  const ServerException([
    this.message = 'Server returned an error.',
    this.statusCode,
  ]);

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No usable network connection.']);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
