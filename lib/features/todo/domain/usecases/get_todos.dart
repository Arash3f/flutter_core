import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/todo/domain/entities/todo.dart';
import 'package:flutter_core/features/todo/domain/repositories/todo_repository.dart';

/// Returns the todos with unfinished items first, then newest first.
class GetTodos implements UseCase<List<Todo>, NoParams> {
  const GetTodos(this._repository);

  final TodoRepository _repository;

  @override
  Future<List<Todo>> call(NoParams input) async {
    final todos = await _repository.getTodos();

    return [...todos]..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return b.createdAt.compareTo(a.createdAt);
      });
  }
}
