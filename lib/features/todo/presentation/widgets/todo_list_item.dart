import 'package:flutter/material.dart';
import 'package:flutter_core/core/utils/colors/dynamic_colors.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_core/core/utils/formatters/formatter.dart';
import 'package:flutter_core/features/todo/domain/entities/todo.dart';

class TodoListItem extends StatelessWidget {
  const TodoListItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsets.symmetric(horizontal: TSizes.lg),
        color: Theme.of(context).colorScheme.errorContainer,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      child: CheckboxListTile(
        value: todo.isCompleted,
        onChanged: (_) => onToggle(),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          todo.title,
          style: textTheme.bodyLarge?.copyWith(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted
                ? DynamicColors.of(context, DynamicColorsName.textMuted)
                : null,
          ),
        ),
        subtitle: Text(
          Formatter.date.formatDate(todo.createdAt),
          style: textTheme.bodySmall,
        ),
      ),
    );
  }
}
