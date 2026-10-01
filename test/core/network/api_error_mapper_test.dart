import 'package:dio/dio.dart';
import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/network/api_error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiErrorMapper.fromRestBody', () {
    test('maps a structured body to ApiFailure', () {
      final failure = ApiErrorMapper.fromRestBody({
        'message': 'Name already taken',
        'status': 409,
        'error_code': 1201,
        'trace_id': 'abc',
      }, statusCode: 409);

      expect(
        failure,
        const ApiFailure(
          message: 'Name already taken',
          statusCode: 409,
          errorCode: 1201,
          traceId: 'abc',
        ),
      );
    });

    test('maps unauthenticated status or error code to AuthFailure', () {
      expect(
        ApiErrorMapper.fromRestBody(null, statusCode: 401),
        const AuthFailure(),
      );
      expect(
        ApiErrorMapper.fromRestBody({'error_code': 900}, statusCode: 400),
        const AuthFailure(),
      );
    });

    test('falls back to ServerFailure for a non-JSON body', () {
      expect(
        ApiErrorMapper.fromRestBody('<html>', statusCode: 502),
        const ServerFailure(statusCode: 502),
      );
    });

    test('accepts FastAPI-style "detail" and numeric strings', () {
      final failure = ApiErrorMapper.fromRestBody({
        'detail': 'Bad input',
        'error_code': '42',
      }, statusCode: 422);

      expect(failure, isA<ApiFailure>());
      failure as ApiFailure;
      expect(failure.message, 'Bad input');
      expect(failure.errorCode, 42);
      expect(failure.statusCode, 422);
    });
  });

  group('ApiErrorMapper.fromDio', () {
    final options = RequestOptions(path: '/x');

    test('timeouts and connection errors are NetworkFailure', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(
          ApiErrorMapper.fromDio(
            DioException(requestOptions: options, type: type),
          ),
          const NetworkFailure(),
        );
      }
    });

    test('bad responses are decoded from the body', () {
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 401,
          data: {'message': 'expired'},
        ),
      );

      expect(ApiErrorMapper.fromDio(error), const AuthFailure());
    });

    test('an unknown error without a cause is UnexpectedFailure', () {
      expect(
        ApiErrorMapper.fromDio(DioException(requestOptions: options)),
        const UnexpectedFailure(),
      );
    });
  });

  test('map passes Failures through and detects socket errors', () {
    const failure = CacheFailure();
    expect(ApiErrorMapper.map(failure), same(failure));
    expect(
      ApiErrorMapper.map(Exception('SocketException: Failed host lookup')),
      const NetworkFailure(),
    );
  });
}
