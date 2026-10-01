import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/error/error_message.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';

/// Yes/no dialog. Resolves to `false` when dismissed by tapping outside.
///
/// Set [destructive] for irreversible actions; the confirm button turns red.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String message,
  String? title,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: title == null ? null : Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel ?? LocaleKeys.actionCancel.tr()),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel ?? LocaleKeys.actionConfirm.tr()),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Floating snack bar. Replaces the one currently shown instead of queueing,
/// so rapid actions do not stack up stale messages.
void showAppToast(BuildContext context, String message, {bool error = false}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: error ? TextStyle(color: scheme.onError) : null,
        ),
        backgroundColor: error ? scheme.error : null,
      ),
    );
}

/// [showAppToast] for a caught error, localized through [describeError].
void showErrorToast(BuildContext context, Object error) =>
    showAppToast(context, describeError(error), error: true);
