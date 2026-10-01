import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/features/auth/domain/usecases/change_password.dart';
import 'package:flutter_core/features/auth/domain/usecases/restore_session.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  setUp(() => repository = FakeAuthRepository());

  group('ChangePassword', () {
    test('rejects a mismatched repeat before calling the server', () async {
      await expectLater(
        ChangePassword(repository)(
          const ChangePasswordParams(
            currentPassword: 'old',
            newPassword: 'new-1',
            repeatPassword: 'new-2',
          ),
        ),
        throwsA(const ValidationFailure(LocaleKeys.errorPasswordMismatch)),
      );
      expect(repository.passwordChanges, isEmpty);
    });

    test('sends only the current and new password', () async {
      await ChangePassword(repository)(
        const ChangePasswordParams(
          currentPassword: 'old',
          newPassword: 'new',
          repeatPassword: 'new',
        ),
      );
      expect(repository.passwordChanges, [('old', 'new')]);
    });
  });

  group('RestoreSession', () {
    test('returns null when no token is stored', () async {
      expect(await RestoreSession(repository)(const NoParams()), isNull);
    });

    test('returns the user for a valid token', () async {
      repository.hasToken = true;
      expect(
        await RestoreSession(repository)(const NoParams()),
        repository.user,
      );
    });

    test('clears a rejected token', () async {
      repository
        ..hasToken = true
        ..currentUserError = const AuthFailure();

      expect(await RestoreSession(repository)(const NoParams()), isNull);
      expect(repository.cleared, isTrue);
    });

    test('keeps the token when offline', () async {
      repository
        ..hasToken = true
        ..currentUserError = const NetworkFailure();

      await expectLater(
        RestoreSession(repository)(const NoParams()),
        throwsA(const NetworkFailure()),
      );
      expect(repository.cleared, isFalse);
    });
  });
}
