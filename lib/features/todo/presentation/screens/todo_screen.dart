import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_core/core/error/error_message.dart';
import 'package:flutter_core/core/utils/constants/sizes.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/widgets/app_ui.dart';
import 'package:flutter_core/core/widgets/feedback.dart';
import 'package:flutter_core/features/todo/domain/entities/todo.dart';
import 'package:flutter_core/features/todo/presentation/providers/todo_providers.dart';
import 'package:flutter_core/features/todo/presentation/widgets/add_todo_field.dart';
import 'package:flutter_core/features/todo/presentation/widgets/todo_list_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodoScreen extends ConsumerWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListProvider);
    final remaining = ref.watch(remainingTodoCountProvider);

    // A write that fails while a list is already on screen must not blank the
    // screen, so it is reported as a snack bar instead of an error state.
    ref.listen(todoListProvider, (previous, next) {
      if (next.hasError && next.hasValue) {
        _showError(context, next.error!);
      }
    });

    // No AppBar / Scaffold: the screen lives inside AdaptiveShell, which owns
    // both. A nested Scaffold would briefly paint ColorScheme.surface before
    // the outer scaffold color, flashing white on every tab change.
    return Column(
      children: [
        AppPageHeader(title: LocaleKeys.todoTitle.tr()),
        const AddTodoField(),
        if (todosAsync.hasValue)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                LocaleKeys.todoRemaining.tr(
                  namedArgs: {'count': remaining.toString()},
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        Expanded(child: _Body(todosAsync: todosAsync)),
      ],
    );
  }

  static void _showError(BuildContext context, Object error) =>
      showErrorToast(context, error);
}

class _Body extends ConsumerWidget {
  const _Body({required this.todosAsync});

  final AsyncValue<List<Todo>> todosAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!todosAsync.hasValue) {
      if (todosAsync.hasError) {
        return _ErrorView(error: todosAsync.error!);
      }
      return const Center(child: CircularProgressIndicator());
    }

    final todos = todosAsync.value!;
    if (todos.isEmpty) {
      return Center(
        child: Text(
          LocaleKeys.todoEmpty.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final notifier = ref.read(todoListProvider.notifier);

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoListItem(
            todo: todo,
            onToggle: () => notifier.toggle(todo.id),
            onDelete: () => notifier.delete(todo.id),
          );
        },
      ),
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TSizes.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: TSizes.md,
          children: [
            Icon(
              Icons.error_outline,
              size: TSizes.iconLg,
              color: Theme.of(context).colorScheme.error,
            ),
            Text(
              describeError(error),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            ElevatedButton(
              onPressed: () => ref.invalidate(todoListProvider),
              child: Text(LocaleKeys.todoRetry.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
