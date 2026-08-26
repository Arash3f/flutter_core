import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/todo/domain/entities/todo.dart';
import 'package:flutter_core/features/todo/domain/repositories/todo_repository.dart';

class ToggleTodo implements UseCase<Todo, String> {
  const ToggleTodo(this._repository);

  final TodoRepository _repository;

  @override
  Future<Todo> call(String id) => _repository.toggleTodo(id);
}
