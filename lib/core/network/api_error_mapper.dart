import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_core/core/error/exceptions.dart';
import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/error/failure_mapper.dart';
import 'package:graphql_flutter/graphql_flutter.dart'
    hide NetworkException, ServerException;

/// Application error codes the client reacts to.
///
/// These are a contract with *your* backend - replace the values when a
/// project starts. Codes not listed here still reach the UI as an
/// [ApiFailure] carrying the server's message.
abstract final class ApiErrorCodes {
  /// The token is missing, expired or revoked. Triggers a refresh attempt.
  static const Set<int> unauthenticated = {401, 900};
}

/// Maps transport errors (Dio, GraphQL, sockets) onto domain [Failure]s.
///
/// Expected error body, for REST responses and GraphQL `extensions` alike:
///
/// ```json
/// { "message": "...", "status": 400, "error_code": 1201, "trace_id": "..." }
/// ```
///
/// Every key is optional; a body that does not match still produces a
/// [ServerFailure] with the HTTP status.
abstract final class ApiErrorMapper {
  static Failure map(Object error) {
    if (error is Failure) return error;
    if (error is DioException) return fromDio(error);
    if (error is OperationException) return fromGraphQL(error);
    if (error is NetworkException ||
        error is ServerException ||
        error is CacheException) {
      return FailureMapper.map(error);
    }

    final text = error.toString().toLowerCase();
    if (text.contains('socket') ||
        text.contains('failed host lookup') ||
        text.contains('connection refused') ||
        text.contains('network is unreachable')) {
      return const NetworkFailure();
    }
    return const UnexpectedFailure();
  }

  static Never mapAndThrow(Object error) => throw map(error);

  static Failure fromDio(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      case DioExceptionType.badCertificate:
      case DioExceptionType.badResponse:
      case DioExceptionType.cancel:
      case DioExceptionType.unknown:
        break;
    }

    final response = error.response;
    if (response != null) {
      return fromRestBody(response.data, statusCode: response.statusCode);
    }
    final inner = error.error;
    return inner == null || inner is DioException
        ? const UnexpectedFailure()
        : map(inner);
  }

  static Failure fromGraphQL(OperationException exception) {
    final graphqlErrors = exception.graphqlErrors;
    if (graphqlErrors.isEmpty) {
      return exception.linkException != null
          ? const NetworkFailure()
          : const ServerFailure();
    }

    final first = graphqlErrors.first;
    final extensions = first.extensions ?? const <String, dynamic>{};
    return _fromFields(
      message: first.message,
      status: _asInt(extensions['status']),
      errorCode: _asInt(extensions['error_code']),
      traceId: extensions['trace_id']?.toString(),
    );
  }

  static Failure fromRestBody(Object? body, {int? statusCode}) {
    if (body is! Map) {
      if (statusCode == 401) return const AuthFailure();
      return ServerFailure(statusCode: statusCode);
    }
    final map = Map<String, dynamic>.from(body);
    return _fromFields(
      message: (map['message'] ?? map['detail'])?.toString(),
      status: _asInt(map['status']) ?? statusCode,
      errorCode: _asInt(map['error_code']),
      traceId: map['trace_id']?.toString(),
    );
  }

  /// For responses read as bytes (file downloads), where Dio cannot decode
  /// the error body for us.
  static Failure fromRestBytes(int? statusCode, List<int> bytes) {
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      decoded = null;
    }
    return fromRestBody(decoded, statusCode: statusCode);
  }

  /// Whether [error] means "the access token is no longer valid".
  static bool isUnauthenticated({int? status, int? errorCode}) =>
      status == 401 || ApiErrorCodes.unauthenticated.contains(errorCode);

  static Failure _fromFields({
    required String? message,
    required int? status,
    required int? errorCode,
    required String? traceId,
  }) {
    if (isUnauthenticated(status: status, errorCode: errorCode)) {
      return const AuthFailure();
    }
    final text = message?.trim();
    return ApiFailure(
      message: (text == null || text.isEmpty) ? 'errorServer' : text,
      statusCode: status,
      errorCode: errorCode,
      traceId: traceId,
    );
  }

  static int? _asInt(Object? value) => switch (value) {
    final int v => v,
    final num v => v.toInt(),
    final String v => int.tryParse(v),
    _ => null,
  };
}
