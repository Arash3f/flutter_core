import 'package:flutter_core/core/network/graphql/graphql_client.dart';
import 'package:flutter_core/core/network/rest/rest_client.dart';
import 'package:flutter_core/core/network/token_refresher.dart';
import 'package:flutter_core/core/utils/local_storage/helper_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

/// The auth feature binds its refresh use case here; see [TokenRefresher].
final tokenRefresherProvider = Provider<TokenRefresher>(
  (ref) => TokenRefresher(),
);

/// Bumped every time a refresh fails and the tokens are wiped.
///
/// The auth session listens to it and flips to anonymous, which in turn makes
/// the router redirect to login. A counter rather than a bool, so two failures
/// in a row still notify.
final authFailureSignalProvider = NotifierProvider<AuthFailureSignal, int>(
  AuthFailureSignal.new,
);

class AuthFailureSignal extends Notifier<int> {
  @override
  int build() => 0;

  void notify() => state++;
}

Future<void> _handleAuthFailure(Ref ref) async {
  await AppStorageHelper.clearTokens();
  ref.read(authFailureSignalProvider.notifier).notify();
}

final restClientProvider = Provider<RestClient>((ref) {
  final refresher = ref.watch(tokenRefresherProvider);
  return RestClient(
    refreshTokens: refresher.call,
    onAuthFailure: () => _handleAuthFailure(ref),
  );
});

final graphQLClientProvider = Provider<GraphQLClient>((ref) {
  final refresher = ref.watch(tokenRefresherProvider);
  return createGraphQLClient(
    refreshTokens: refresher.call,
    onAuthFailure: () => _handleAuthFailure(ref),
  );
});
