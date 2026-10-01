import 'package:dio/dio.dart';
import 'package:flutter_core/core/network/api_error_mapper.dart';
import 'package:flutter_core/core/utils/constants/api.dart';
import 'package:flutter_core/core/utils/local_storage/helper_functions.dart';

/// Dio wrapper that every REST data source goes through.
///
/// - adds `Authorization: Bearer <token>` and `Accept-Language` to each request
/// - on HTTP 401 refreshes the token once and replays the request
/// - when the refresh fails, calls [onAuthFailure] so the app can log out
///
/// Data sources call [send], which turns any Dio error into a domain
/// `Failure`, so `package:dio` never leaks past the data layer.
class RestClient {
  RestClient({Dio? dio, this._refreshTokens, this._onAuthFailure})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              headers: const {'Accept': 'application/json'},
            ),
          ) {
    _dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  /// Put `{RestClient.skipAuth: true}` in `Options.extra` for calls that must
  /// not send a token or trigger a refresh: login, refresh itself, public
  /// endpoints. Without it, a 401 from the refresh call would wait on itself.
  static const String skipAuth = 'skip_auth';

  static const String _retried = 'auth_retried';

  final Dio _dio;
  final Future<bool> Function()? _refreshTokens;
  final Future<void> Function()? _onAuthFailure;

  /// Raw access for uploads, downloads and other special cases. Prefer [send].
  Dio get dio => _dio;

  /// Runs [request] and rethrows any failure as a domain `Failure`.
  ///
  /// ```dart
  /// final user = await client.send((dio) async {
  ///   final response = await dio.get<Map<String, dynamic>>('/auth/me');
  ///   return UserModel.fromJson(response.data ?? const {});
  /// });
  /// ```
  Future<T> send<T>(Future<T> Function(Dio dio) request) async {
    try {
      return await request(_dio);
    } on DioException catch (error) {
      throw ApiErrorMapper.fromDio(error);
    }
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept-Language'] =
        AppStorageHelper.getActiveLanguage().code;
    if (options.extra[skipAuth] != true) {
      final token = await AppStorageHelper.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final options = error.requestOptions;
    final refresh = _refreshTokens;
    final shouldRefresh =
        error.response?.statusCode == 401 &&
        options.extra[skipAuth] != true &&
        options.extra[_retried] != true &&
        refresh != null;

    if (!shouldRefresh) {
      handler.next(error);
      return;
    }

    if (!await refresh()) {
      await _onAuthFailure?.call();
      handler.next(error);
      return;
    }

    options.extra[_retried] = true;
    try {
      // `fetch` re-runs the interceptors, so the new token is picked up.
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
