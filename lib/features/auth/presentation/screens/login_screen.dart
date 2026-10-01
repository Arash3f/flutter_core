import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/widgets/app_ui.dart';
import 'package:flutter_core/core/widgets/appearance_controls.dart';
import 'package:flutter_core/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Username / password sign-in.
///
/// Does not navigate on success: the router's auth redirect moves the user to
/// home as soon as the session flips to authenticated.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    await ref
        .read(authSessionProvider.notifier)
        .login(
          username: _usernameController.text,
          password: _passwordController.text,
        );
    if (mounted) setState(() => _submitting = false);
  }

  String? _required(String? value, String fieldKey) {
    if (value == null || value.trim().isEmpty) {
      return LocaleKeys.inputRequired.tr(
        namedArgs: {'fieldName': fieldKey.tr()},
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final error = ref.watch(authSessionProvider).value?.errorMessage;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: AppAtmosphere(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: AppearanceToolbar(),
                        ),
                        const SizedBox(height: 24),
                        const Center(child: AppMark(size: 64)),
                        const SizedBox(height: 14),
                        Text(
                          LocaleKeys.brand.tr(),
                          textAlign: TextAlign.center,
                          style: text.headlineMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          LocaleKeys.splashTagline.tr(),
                          textAlign: TextAlign.center,
                          style: text.bodySmall?.copyWith(
                            color: appMutedOf(context),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppSectionCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                LocaleKeys.loginTitle.tr(),
                                style: text.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                LocaleKeys.loginSubtitle.tr(),
                                style: text.bodySmall?.copyWith(
                                  color: appMutedOf(context),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                onFieldSubmitted: (_) =>
                                    _passwordFocus.requestFocus(),
                                decoration: InputDecoration(
                                  labelText: LocaleKeys.username.tr(),
                                  prefixIcon: const Icon(Icons.person_outline),
                                ),
                                validator: (value) =>
                                    _required(value, LocaleKeys.username),
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: LocaleKeys.password.tr(),
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    _required(value, LocaleKeys.password),
                              ),
                              if (error != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  error,
                                  style: TextStyle(color: scheme.error),
                                ),
                              ],
                              const SizedBox(height: 18),
                              FilledButton(
                                onPressed: _submitting ? null : _submit,
                                child: _submitting
                                    ? SizedBox.square(
                                        dimension: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: scheme.onPrimary,
                                        ),
                                      )
                                    : Text(LocaleKeys.loginSubmit.tr()),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
