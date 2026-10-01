import 'package:equatable/equatable.dart';
import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/features/auth/domain/repositories/auth_repository.dart';

class ChangePasswordParams extends Equatable {
  const ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
    required this.repeatPassword,
  });

  final String currentPassword;
  final String newPassword;
  final String repeatPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword, repeatPassword];
}

class ChangePassword implements UseCase<void, ChangePasswordParams> {
  const ChangePassword(this._repository);

  final AuthRepository _repository;

  /// The "repeat" field never leaves the device: matching it is a UI-level
  /// rule enforced here, so every screen that changes a password obeys it.
  @override
  Future<void> call(ChangePasswordParams input) async {
    if (input.newPassword != input.repeatPassword) {
      throw const ValidationFailure(LocaleKeys.errorPasswordMismatch);
    }
    await _repository.changePassword(
      currentPassword: input.currentPassword,
      newPassword: input.newPassword,
    );
  }
}
