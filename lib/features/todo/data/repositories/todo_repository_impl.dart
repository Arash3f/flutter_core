import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/error/failure_mapper.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/core/utils/logging/logger.dart';
import 'package:flutter_core/features/todo/data/datasources/todo_local_data_source.dart';
import 'package:flutter_core/features/todo/data/models/todo_model.dart';
import 'package:flutter_core/features/todo/domain/entities/todo.dart';
import 'package:flutter_core/features/todo/domain/repositories/todo_repository.dart';

/// Translates data-source exceptions into domain `Failure`s. This is the only
/// layer that knows both vocabularies.
class TodoRepositoryImpl implements TodoRepository {
  const TodoRepositoryImpl(this._localDataSource);

  final TodoLocalDataSource _localDataSource;

  @override
  Future<List<Todo>> getTodos() => _guard(_localDataSource.readAll);

  @override
  Future<Todo> addTodo(String title) => _guard(() async {
    final todos = await _localDataSource.readAll();

    final todo = TodoModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );

    await _localDataSource.writeAll([...todos, todo]);
    return todo;
  });

  @override
  Future<Todo> toggleTodo(String id) => _guard(() async {
    final todos = await _localDataSource.readAll();
    final index = todos.indexWhere((todo) => todo.id == id);

    if (index == -1) {
      throw const ValidationFailure(LocaleKeys.errorTodoNotFound);
    }

    final toggled = TodoModel.fromEntity(todos[index].toggled());
    final updated = [...todos]..[index] = toggled;

    await _localDataSource.writeAll(updated);
    return toggled;
  });

  @override
  Future<void> deleteTodo(String id) => _guard(() async {
    final todos = await _localDataSource.readAll();
    await _localDataSource.writeAll(
      todos.where((todo) => todo.id != id).toList(),
    );
  });

  Future<T> _guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } on Failure {
      rethrow;
    } on Exception catch (error, stackTrace) {
      LoggerService.error('TodoRepository failure', error, stackTrace);
      FailureMapper.mapAndThrow(error);
    } on Object catch (error, stackTrace) {
      LoggerService.error(
        'TodoRepository unexpected failure',
        error,
        stackTrace,
      );
      throw const UnexpectedFailure();
    }
  }
}
