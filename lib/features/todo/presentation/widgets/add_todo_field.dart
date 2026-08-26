import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/features/todo/presentation/providers/todo_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Owns its own `TextEditingController`, which is why this is the only
/// stateful widget in the feature.
class AddTodoField extends ConsumerStatefulWidget {
  const AddTodoField({super.key});

  @override
  ConsumerState<AddTodoField> createState() => _AddTodoFieldState();
}

class _AddTodoFieldState extends ConsumerState<AddTodoField> {
  final TextEditingController _controller = TextEditingController();
  bool _canSubmit = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final canSubmit = value.trim().isNotEmpty;
    if (canSubmit != _canSubmit) {
      setState(() => _canSubmit = canSubmit);
    }
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final title = _controller.text;
    _controller.clear();
    _onChanged('');

    await ref.read(todoListProvider.notifier).add(title);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.md),
      child: Row(
        spacing: TSizes.sm,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: LocaleKeys.todoAddHint.tr(),
              ),
              onChanged: _onChanged,
              onSubmitted: (_) => _submit(),
            ),
          ),
          ElevatedButton(
            onPressed: _canSubmit ? _submit : null,
            child: Text(LocaleKeys.todoAdd.tr()),
          ),
        ],
      ),
    );
  }
}
