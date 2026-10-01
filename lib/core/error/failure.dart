import 'package:equatable/equatable.dart';

/// Domain-level error type.
///
/// Failures implement [Exception] on purpose: the data layer throws them and
/// the presentation layer catches them through `AsyncValue.guard`, so no
/// `Either`/`Result` wrapper has to be threaded through every signature.
///
/// [message] is either a human-readable string or an `easy_localization` key
/// (see [describeError]). Prefer locale keys for user-facing copy.
sealed class Failure extends Equatable implements Exception {
  const Failure(this.message, {this.namedArgs});

  final String message;

  /// Optional placeholders when [message] is a locale key.
  final Map<String, String>? namedArgs;

  @override
  List<Object?> get props => [message, namedArgs];

  @override
  String toString() => '$runtimeType: $message';
}

/// Reading from or writing to on-device storage failed.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'errorCache']);
}

/// The backend answered with an error status.
final class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'errorServer',
    this.statusCode,
    Map<String, String>? namedArgs,
  }) : super(message, namedArgs: namedArgs);

  final int? statusCode;

  @override
  List<Object?> get props => [message, namedArgs, statusCode];
}

/// A structured backend error: the body carried an application `error_code`
/// (REST JSON body or GraphQL `extensions`), not just an HTTP status.
///
/// [message] is whatever the backend sent. When it contains a space it is
/// shown verbatim, otherwise it is treated as a locale key (see
/// [describeError]). Branch on [errorCode] for behavior, never on [message].
final class ApiFailure extends ServerFailure {
  const ApiFailure({
    super.message,
    super.statusCode,
    super.namedArgs,
    this.errorCode,
    this.traceId,
  });

  /// Backend-specific code. Document the ones your API uses next to
  /// `ApiErrorCodes` in `core/network/api_error_mapper.dart`.
  final int? errorCode;

  /// Correlation id for support requests and server logs.
  final String? traceId;

  @override
  List<Object?> get props => [
    message,
    namedArgs,
    statusCode,
    errorCode,
    traceId,
  ];
}

/// The session is gone: the access token was rejected and could not be
/// refreshed. The auth feature reacts by sending the user to login.
final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'errorAuth']);
}

/// The device has no usable connection.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'errorNetwork']);
}

/// Input rejected by a domain rule before any I/O happened.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.namedArgs});
}

/// Anything that was not anticipated. Keep the original error for the logs.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'errorUnexpected']);
}
