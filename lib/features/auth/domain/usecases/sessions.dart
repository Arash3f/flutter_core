import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/auth/domain/entities/user_session.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

/// Active sessions, the current device first.
class GetSessions implements UseCase<List<UserSession>, NoParams> {
  const GetSessions(this._repository);

  final AuthRepository _repository;

  @override
  Future<List<UserSession>> call(NoParams input) async {
    final sessions = await _repository.getSessions();
    return [
      ...sessions.where((session) => session.isCurrent),
      ...sessions.where((session) => !session.isCurrent),
    ];
  }
}

class RevokeSession implements UseCase<void, String> {
  const RevokeSession(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(String sessionId) => _repository.revokeSession(sessionId);
}
