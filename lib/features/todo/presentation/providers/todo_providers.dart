import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:flutter_core/features/todo/data/repositories/todo_repository_impl.dart';
import 'package:flutter_core/features/todo/domain/entities/todo.dart';
import 'package:flutter_core/features/todo/domain/repositories/todo_repository.dart';
import 'package:flutter_core/features/todo/domain/usecases/add_todo.dart';
import 'package:flutter_core/features/todo/domain/usecases/delete_todo.dart';
import 'package:flutter_core/features/todo/domain/usecases/get_todos.dart';
import 'package:flutter_core/features/todo/domain/usecases/toggle_todo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// This file is the wiring diagram of the feature. Every provider exposes an
/// abstract type, so a test can override any single layer with a fake.

// ---------------------------------------------------------------- data layer

final todoLocalDataSourceProvider = Provider<TodoLocalDataSource>(
  (ref) => const TodoLocalDataSourceImpl(),
);

final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => TodoRepositoryImpl(ref.watch(todoLocalDataSourceProvider)),
);

// -------------------------------------------------------------- domain layer

final getTodosProvider = Provider<GetTodos>(
  (ref) => GetTodos(ref.watch(todoRepositoryProvider)),
);

final addTodoProvider = Provider<AddTodo>(
  (ref) => AddTodo(ref.watch(todoRepositoryProvider)),
);

final toggleTodoProvider = Provider<ToggleTodo>(
  (ref) => ToggleTodo(ref.watch(todoRepositoryProvider)),
);

final deleteTodoProvider = Provider<DeleteTodo>(
  (ref) => DeleteTodo(ref.watch(todoRepositoryProvider)),
);

// ---------------------------------------------------------- presentation layer

/// Owns the screen state. Every mutation re-reads through the use case rather
/// than patching the list locally, so storage stays the single source of truth.
class TodoListNotifier extends AsyncNotifier<List<Todo>> {
  /// `watch` here, `read` in the mutations: the notifier should rebuild when
  /// the use case is replaced (a test override, for instance), but a button
  /// press must not subscribe to it.
  @override
  Future<List<Todo>> build() =>
      ref.watch(getTodosProvider).call(const NoParams());

  Future<void> add(String title) =>
      _mutate(() => ref.read(addTodoProvider).call(title));

  Future<void> toggle(String id) =>
      _mutate(() => ref.read(toggleTodoProvider).call(id));

  Future<void> delete(String id) =>
      _mutate(() => ref.read(deleteTodoProvider).call(id));

  Future<void> refresh() => _mutate(() async {});

  Future<List<Todo>> _load() =>
      ref.read(getTodosProvider).call(const NoParams());

  /// Keeps the previous list on screen while the write is in flight, then
  /// reloads.
  ///
  /// The `copyWithPrevious` on the result is what matters: `AsyncValue.guard`
  /// returns a bare `AsyncError`, so without it a failed write would blank the
  /// list instead of leaving it visible behind an error message.
  Future<void> _mutate(Future<void> Function() operation) async {
    final previous = state;
    state = const AsyncValue<List<Todo>>.loading().copyWithPrevious(previous);

    final result = await AsyncValue.guard(() async {
      await operation();
      return _load();
    });

    state = result.copyWithPrevious(previous);
  }
}

final todoListProvider =
    AsyncNotifierProvider<TodoListNotifier, List<Todo>>(TodoListNotifier.new);

/// Derived state. Recomputes only when the count actually changes.
final remainingTodoCountProvider = Provider<int>((ref) {
  final todos = ref.watch(todoListProvider).value ?? const <Todo>[];
  return todos.where((todo) => !todo.isCompleted).length;
});
