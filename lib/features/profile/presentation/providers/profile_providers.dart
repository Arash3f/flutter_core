import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/auth/domain/entities/user_session.dart';
import 'package:flutter_core/features/auth/domain/usecases/change_password.dart';
import 'package:flutter_core/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Profile is presentation-only: every operation is an auth use case, adapted
// here to screen state.

/// Active sessions of the current user. Auto-disposed, so reopening the tab
/// fetches a fresh list.
final sessionsProvider = FutureProvider.autoDispose<List<UserSession>>(
  (ref) => ref.watch(getSessionsUseCaseProvider).call(const NoParams()),
);

/// Revokes a session, then reloads the list.
Future<void> revokeSession(WidgetRef ref, String sessionId) async {
  await ref.read(revokeSessionUseCaseProvider).call(sessionId);
  ref.invalidate(sessionsProvider);
}

/// Submit state of the change-password form: `AsyncData(null)` when idle,
/// `AsyncLoading` while saving, `AsyncError` when the last attempt failed.
class ChangePasswordNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  /// Returns `true` on success.
  Future<bool> submit(ChangePasswordParams params) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(changePasswordUseCaseProvider).call(params),
    );
    return !state.hasError;
  }
}

final changePasswordProvider =
    AsyncNotifierProvider.autoDispose<ChangePasswordNotifier, void>(
      ChangePasswordNotifier.new,
    );
