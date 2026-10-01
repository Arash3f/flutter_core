import 'package:equatable/equatable.dart';
import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

class LoginParams extends Equatable {
  const LoginParams({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}

class Login implements UseCase<void, LoginParams> {
  const Login(this._repository);

  final AuthRepository _repository;

  /// Usernames are trimmed (a trailing space from autofill is never
  /// intended); passwords are sent exactly as typed.
  @override
  Future<void> call(LoginParams input) => _repository.login(
    username: input.username.trim(),
    password: input.password,
  );
}
