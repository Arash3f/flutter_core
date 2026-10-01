import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser implements UseCase<AuthUser, NoParams> {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthUser> call(NoParams input) => _repository.getCurrentUser();
}
