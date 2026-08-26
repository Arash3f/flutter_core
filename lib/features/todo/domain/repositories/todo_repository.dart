import 'package:flutter_core/features/todo/domain/entities/todo.dart';

/// The contract the domain layer depends on.
///
/// The implementation lives in `data/`, which is what lets the domain stay
/// unaware of `SharedPreferences`, HTTP, or any other detail.
///
/// Throws a `Failure` on error.
abstract interface class TodoRepository {
  Future<List<Todo>> getTodos();

  Future<Todo> addTodo(String title);

  Future<Todo> toggleTodo(String id);

  Future<void> deleteTodo(String id);
}
