import 'dart:async';
import 'dart:convert';

import 'package:flutter_core/core/network/api_error_mapper.dart';
import 'package:flutter_core/core/utils/constants/api.dart';
import 'package:flutter_core/core/utils/local_storage/helper_functions.dart';
import 'package:flutter_core/core/utils/local_storage/shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;

/// Builds the app-wide [GraphQLClient].
///
/// Link chain, in request order:
/// 1. [_LocaleLink] - `Accept-Language` from the stored language
/// 2. [AuthLink] - `Authorization: Bearer <token>`
/// 3. [RefreshLink] - refresh once on an auth error and replay
/// 4. [HttpLink] - the actual POST to [ApiConfig.graphqlUrl]
///
/// Queries default to cache-and-network (instant paint from the persisted
/// cache, then fresh data); mutations always hit the network.
GraphQLClient createGraphQLClient({
  required Future<bool> Function() refreshTokens,
  required Future<void> Function() onAuthFailure,
  http.Client? httpClient,
  Store? store,
}) {
  final link = Link.from([
    _LocaleLink(),
    AuthLink(
      getToken: () async {
        final token = await AppStorageHelper.getAccessToken();
        return (token == null || token.isEmpty) ? null : 'Bearer $token';
      },
    ),
    RefreshLink(refresh: refreshTokens, onRefreshFailed: onAuthFailure),
    HttpLink(
      ApiConfig.graphqlUrl,
      httpClient: httpClient,
      defaultHeaders: const {'Accept': 'application/json'},
    ),
  ]);

  return GraphQLClient(
    link: link,
    cache: GraphQLCache(store: store ?? PrefsGraphQLStore()),
    defaultPolicies: DefaultPolicies(
      query: Policies(
        fetch: FetchPolicy.cacheAndNetwork,
        error: ErrorPolicy.none,
        cacheReread: CacheRereadPolicy.mergeOptimistic,
      ),
      mutate: Policies(fetch: FetchPolicy.networkOnly, error: ErrorPolicy.none),
    ),
  );
}

/// Refreshes the token once when a response carries an auth error, then
/// replays the request. Single-flight is handled by `TokenRefresher`.
///
/// Operations named in [skipOperations] (login, the refresh mutation itself)
/// are passed through untouched: a 401 there means bad credentials, not an
/// expired session.
class RefreshLink extends Link {
  RefreshLink({
    required this.refresh,
    required this.onRefreshFailed,
    this.skipOperations = const {'Login', 'RefreshToken'},
  });

  final Future<bool> Function() refresh;
  final Future<void> Function() onRefreshFailed;
  final Set<String> skipOperations;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) async* {
    if (forward == null) return;

    if (skipOperations.contains(request.operation.operationName)) {
      yield* forward(request);
      return;
    }

    await for (final response in forward(request)) {
      if (!_isAuthError(response)) {
        yield response;
        continue;
      }

      if (!await refresh()) {
        await onRefreshFailed();
        yield response;
        return;
      }

      // AuthLink runs again on replay and reads the new token.
      yield* forward(request);
      return;
    }
  }

  static bool _isAuthError(Response response) {
    final errors = response.errors;
    if (errors == null) return false;
    return errors.any((error) {
      final extensions = error.extensions;
      return ApiErrorMapper.isUnauthenticated(
        status: _asInt(extensions?['status']),
        errorCode: _asInt(extensions?['error_code']),
      );
    });
  }

  static int? _asInt(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value');
}

class _LocaleLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    final updated = request.updateContextEntry<HttpLinkHeaders>(
      (headers) => HttpLinkHeaders(
        headers: {
          ...?headers?.headers,
          'Accept-Language': AppStorageHelper.getActiveLanguage().code,
        },
      ),
    );
    return forward!(updated);
  }
}

/// SharedPreferences-backed normalized cache, so the last query results
/// survive an app restart and screens paint before the network answers.
///
/// Every entity is one prefs entry (`<prefix><dataId>`), plus an index of keys
/// so [reset] can wipe them without touching unrelated preferences. Reads are
/// memoized in memory; writes are fire-and-forget.
class PrefsGraphQLStore extends Store {
  PrefsGraphQLStore({this.prefix = 'gql_cache:'});

  final String prefix;
  final Map<String, Map<String, dynamic>?> _memory = {};

  String get _indexKey => '${prefix}__keys';

  @override
  Map<String, dynamic>? get(String dataId) {
    if (_memory.containsKey(dataId)) return _memory[dataId];

    final raw = SharedPrefs.readData<String>('$prefix$dataId');
    Map<String, dynamic>? value;
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) value = Map<String, dynamic>.from(decoded);
      } on FormatException {
        value = null;
      }
    }
    return _memory[dataId] = value;
  }

  @override
  void put(String dataId, Map<String, dynamic>? value) {
    _memory[dataId] = value;
    unawaited(_persist(dataId, value));
  }

  @override
  void putAll(Map<String, Map<String, dynamic>?> data) => data.forEach(put);

  @override
  void delete(String dataId) {
    _memory.remove(dataId);
    unawaited(SharedPrefs.removeData('$prefix$dataId'));
    unawaited(_updateIndex((keys) => keys.remove(dataId)));
  }

  @override
  Map<String, Map<String, dynamic>?> toMap() => Map.unmodifiable(_memory);

  @override
  void reset() {
    for (final key in _keys()) {
      unawaited(SharedPrefs.removeData('$prefix$key'));
    }
    unawaited(SharedPrefs.removeData(_indexKey));
    _memory.clear();
  }

  List<String> _keys() =>
      SharedPrefs.readData<List<String>>(_indexKey) ?? const [];

  Future<void> _persist(String dataId, Map<String, dynamic>? value) async {
    if (value == null) {
      await SharedPrefs.removeData('$prefix$dataId');
      await _updateIndex((keys) => keys.remove(dataId));
      return;
    }
    await SharedPrefs.saveData('$prefix$dataId', jsonEncode(value));
    await _updateIndex((keys) {
      if (keys.contains(dataId)) return false;
      keys.add(dataId);
      return true;
    });
  }

  /// [change] mutates the list and returns whether anything changed.
  Future<void> _updateIndex(bool Function(List<String> keys) change) async {
    final keys = List<String>.from(_keys());
    if (change(keys)) await SharedPrefs.saveData(_indexKey, keys);
  }
}
