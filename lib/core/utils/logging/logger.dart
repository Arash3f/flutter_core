import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class LoggerService {
  const LoggerService._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(methodCount: 2, errorMethodCount: 8),
    // Release builds only keep warnings and errors, so debug traces never leak
    // into production logs.
    level: kDebugMode ? Level.debug : Level.warning,
  );

  static void debug(Object? message) => _logger.d(message);

  static void info(Object? message) => _logger.i(message);

  static void warning(Object? message) => _logger.w(message);

  static void error(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
}
