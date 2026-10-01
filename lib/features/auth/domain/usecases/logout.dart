import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

class Logout implements UseCase<void, NoParams> {
  const Logout(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams input) => _repository.logout();
}

class LogoutAll implements UseCase<void, NoParams> {
  const LogoutAll(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams input) => _repository.logoutAll();
}
