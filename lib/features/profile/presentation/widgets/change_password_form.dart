import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/error/error_message.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/utils/validators/validation.dart';
import 'package:flutter_core/core/widgets/app_ui.dart';
import 'package:flutter_core/core/widgets/feedback.dart';
import 'package:flutter_core/features/auth/domain/usecases/change_password.dart';
import 'package:flutter_core/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePasswordForm extends ConsumerStatefulWidget {
  const ChangePasswordForm({super.key});

  @override
  ConsumerState<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends ConsumerState<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _repeat = TextEditingController();

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _repeat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(changePasswordProvider.notifier)
        .submit(
          ChangePasswordParams(
            currentPassword: _current.text,
            newPassword: _next.text,
            repeatPassword: _repeat.text,
          ),
        );
    if (!ok || !mounted) return;
    _formKey.currentState!.reset();
    for (final controller in [_current, _next, _repeat]) {
      controller.clear();
    }
    showAppToast(context, LocaleKeys.profilePasswordChanged.tr());
  }

  @override
  Widget build(BuildContext context) {
    final submit = ref.watch(changePasswordProvider);
    final busy = submit.isLoading;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AppSectionCard(
            child: Column(
              spacing: 12,
              children: [
                _PasswordField(
                  controller: _current,
                  labelKey: LocaleKeys.profileCurrentPassword,
                  validator: (value) => (value == null || value.isEmpty)
                      ? LocaleKeys.inputRequired.tr(
                          namedArgs: {
                            'fieldName': LocaleKeys.profileCurrentPassword.tr(),
                          },
                        )
                      : null,
                ),
                _PasswordField(
                  controller: _next,
                  labelKey: LocaleKeys.profileNewPassword,
                  validator: ValidatorHelper.validatePassword,
                ),
                _PasswordField(
                  controller: _repeat,
                  labelKey: LocaleKeys.profileRePassword,
                  validator: (value) => value != _next.text
                      ? LocaleKeys.errorPasswordMismatch.tr()
                      : null,
                ),
              ],
            ),
          ),
          if (submit.error case final Object error) ...[
            const SizedBox(height: 12),
            Text(
              describeError(error),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: busy ? null : _save,
            child: busy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(LocaleKeys.profilePasswordSave.tr()),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.labelKey,
    required this.validator,
  });

  final TextEditingController controller;
  final String labelKey;
  final FormFieldValidator<String> validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: true,
      autofillHints: const [AutofillHints.password],
      decoration: InputDecoration(labelText: labelKey.tr()),
      validator: validator,
    );
  }
}
