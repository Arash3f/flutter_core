import 'package:flutter/widgets.dart';

/// Shows [child] only when [allowed]; otherwise [fallback] (nothing by default).
///
/// Kept dumb on purpose - the caller decides, usually with
/// `ref.watch(authSessionProvider).value?.hasPermission('...')`. Hiding a
/// button is a convenience, not security: the backend must still enforce it.
class PermissionGate extends StatelessWidget {
  const PermissionGate({
    required this.allowed,
    required this.child,
    this.fallback,
    super.key,
  });

  final bool allowed;
  final Widget child;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (allowed) return child;
    return fallback ?? const SizedBox.shrink();
  }
}
