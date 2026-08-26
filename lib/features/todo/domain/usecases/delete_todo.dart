import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/features/todo/domain/repositories/todo_repository.dart';

class DeleteTodo implements UseCase<void, String> {
  const DeleteTodo(this._repository);

  final TodoRepository _repository;

  @override
  Future<void> call(String id) => _repository.deleteTodo(id);
}
