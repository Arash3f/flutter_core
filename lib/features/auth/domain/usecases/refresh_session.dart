import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

/// Returns `true` when a new token pair was stored. Bound into the network
/// layer's `TokenRefresher` by the auth session.
class RefreshSession implements UseCase<bool, NoParams> {
  const RefreshSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<bool> call(NoParams input) => _repository.refreshSession();
}
