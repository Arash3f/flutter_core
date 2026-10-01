# Network

HTTP plumbing shared by every feature. Two clients ship side by side, both
already wired for auth, refresh and error mapping:

| Client | Package | File | Provider |
|---|---|---|---|
| REST | [dio](https://pub.dev/packages/dio) | [`rest/rest_client.dart`](./rest/rest_client.dart) | `restClientProvider` |
| GraphQL | [graphql_flutter](https://pub.dev/packages/graphql_flutter) | [`graphql/graphql_client.dart`](./graphql/graphql_client.dart) | `graphQLClientProvider` |

Most backends only need one. See [Removing a client](#removing-a-client).

Data sources are the only place that touches these clients. Repositories and
everything above them only ever see domain `Failure`s.

## Configuration

[`ApiConfig`](../utils/constants/api.dart) resolves the base URL in this
order:

1. `--dart-define=API_BASE_URL=...`
2. debug builds: `http://127.0.0.1:8000`
3. release builds: `https://api.example.com` (edit this when a project starts)

```shell
flutter run --dart-define=API_BASE_URL=https://staging.example.com
flutter run --dart-define=GRAPHQL_PATH=/api/graphql   # default /graphql
```

From the Android emulator the host machine is `10.0.2.2`; from a USB phone run
`adb reverse tcp:8000 tcp:8000` so `127.0.0.1` reaches your machine.

## REST

```dart
class ProductRestDataSource {
  const ProductRestDataSource(this._client);

  final RestClient _client;

  Future<List<ProductModel>> list() => _client.send((dio) async {
        final response = await dio.get<List<dynamic>>('/products');
        return ProductModel.listFromJson(response.data);
      });
}

final productDataSourceProvider = Provider(
  (ref) => ProductRestDataSource(ref.watch(restClientProvider)),
);
```

`send` turns any `DioException` into a `Failure`, so `package:dio` never leaks
out of the data source. Every request automatically gets:

- `Accept-Language` from the stored app language
- `Authorization: Bearer <access token>` when one is stored
- one refresh-and-replay on HTTP 401

Calls that must not carry a token or trigger a refresh (login, the refresh
call itself, public endpoints) opt out:

```dart
dio.post<Map<String, dynamic>>(
  '/auth/login',
  data: body,
  options: Options(extra: {RestClient.skipAuth: true}),
);
```

Without `skipAuth` on the refresh call, its own 401 would wait on the refresh
that is already running.

**Uploads:** a `FormData` body is a stream and cannot be replayed. If an upload
gets a 401 the refresh still happens, but the retry fails; let the user tap
again, or build a fresh `FormData` and retry in the data source.

## GraphQL

```dart
final result = await client.query(
  QueryOptions(document: gql(r'query Products { products { id name } }')),
);
if (result.hasException) throw ApiErrorMapper.fromGraphQL(result.exception!);
```

Link chain, in request order:

```
_LocaleLink ─▶ AuthLink ─▶ RefreshLink ─▶ HttpLink
```

`RefreshLink` refreshes once when a response carries an auth error and replays
the operation. Operations named in `skipOperations` (default `Login` and
`RefreshToken`) pass straight through; rename them to match your schema.

Query results are cached in SharedPreferences (`PrefsGraphQLStore`), so screens
paint from the last known data on a cold start. Queries default to
`cacheAndNetwork`, mutations to `networkOnly`.

## Error contract

[`ApiErrorMapper`](./api_error_mapper.dart) expects this body, as REST JSON or
in GraphQL `extensions`. Every key is optional:

```json
{ "message": "Name already taken", "status": 409, "error_code": 1201, "trace_id": "..." }
```

| Input | Failure |
|---|---|
| timeout, connection error, socket error | `NetworkFailure` |
| status 401, or `error_code` in `ApiErrorCodes.unauthenticated` | `AuthFailure` |
| any other structured error | `ApiFailure` (message, status, code, trace id) |
| error status with a non-JSON body | `ServerFailure(statusCode)` |
| anything else | `UnexpectedFailure` |

`message` is shown verbatim when it contains a space (a sentence from the
backend); otherwise it is treated as a locale key. Branch on `errorCode` for
behavior, never on the message text.

Edit `ApiErrorCodes` to match your backend's codes.

## Token refresh

```
request ─401─▶ TokenRefresher ─▶ RefreshSession use case ─▶ POST /auth/refresh
                    │ ok: replay request with the new token
                    └ failed: clear tokens ─▶ AuthFailureSignal ─▶ session = anonymous ─▶ router ─▶ /login
```

- [`TokenRefresher`](./token_refresher.dart) is **single-flight**: ten requests
  failing together trigger one refresh. Backends that rotate refresh tokens
  invalidate the old token on first use, so parallel refreshes would log the
  user out.
- The refresh logic lives in the auth feature, which depends on this layer.
  To avoid a dependency cycle, the auth session *binds* its use case into the
  refresher at runtime, and this layer reports failures through
  `authFailureSignalProvider` instead of calling the auth feature.

## Removing a client

**Only REST:** delete `graphql/`, `graphQLClientProvider`,
`ApiErrorMapper.fromGraphQL` and its `OperationException` branch,
`auth_graphql_data_source.dart`, `ApiConfig.graphqlPath`/`graphqlUrl`, then
remove `graphql_flutter` and `http` from `pubspec.yaml`.

**Only GraphQL:** delete `rest/`, `restClientProvider`,
`ApiErrorMapper.fromDio` and its `DioException` branch, `AuthRestDataSource`,
switch `authRemoteDataSourceProvider` to `AuthGraphQLDataSource`, then remove
`dio` from `pubspec.yaml`.

Run `flutter analyze` afterwards. The analyzer lists every remaining reference.
