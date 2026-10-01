import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

/// Decides at startup whether the stored tokens still belong to a user.
///
/// - no stored token: `null`
/// - token rejected (and the network layer's refresh failed): clears it,
///   returns `null`
/// - any other failure (offline, server down): rethrown and the tokens are
///   **kept**, so a user who opens the app on a plane is not logged out
class RestoreSession implements UseCase<AuthUser?, NoParams> {
  const RestoreSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthUser?> call(NoParams input) async {
    if (!await _repository.hasSession()) return null;
    try {
      return await _repository.getCurrentUser();
    } on AuthFailure {
      await _repository.clearSession();
      return null;
    }
  }
}
