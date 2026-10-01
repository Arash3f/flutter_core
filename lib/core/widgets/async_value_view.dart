import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/error/error_message.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Renders an [AsyncValue] with the app's standard loading and error views.
///
/// ```dart
/// AsyncValueView(
///   value: ref.watch(sessionsProvider),
///   onRetry: () => ref.invalidate(sessionsProvider),
///   builder: (context, sessions) => SessionsList(sessions),
/// )
/// ```
///
/// While a refresh is in flight the previous data stays on screen
/// (`AsyncValue.when` prefers data over loading by default).
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.builder,
    this.onRetry,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: (data) => builder(context, data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          ErrorView(message: describeError(error), onRetry: onRetry),
    );
  }
}

/// Centered error icon, message and optional retry button.
class ErrorView extends StatelessWidget {
  const ErrorView({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: TSizes.md,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null)
              FilledButton.tonal(
                onPressed: onRetry,
                child: Text(LocaleKeys.actionRetry.tr()),
              ),
          ],
        ),
      ),
    );
  }
}

/// Friendly placeholder for an empty list, with an optional call to action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: scheme.primary),
            ),
            const SizedBox(height: TSizes.md),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: TSizes.sm),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: text.bodyMedium,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: TSizes.lg),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
