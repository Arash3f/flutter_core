import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/usecase/usecase.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/features/todo/domain/entities/todo.dart';
import 'package:flutter_core/features/todo/domain/repositories/todo_repository.dart';

class AddTodo implements UseCase<Todo, String> {
  const AddTodo(this._repository);

  static const int maxTitleLength = 120;

  final TodoRepository _repository;

  /// The business rule lives here rather than in the widget, so the same
  /// constraint holds no matter which screen adds a todo.
  ///
  /// `async` matters: a validation error has to arrive as a rejected future,
  /// not as a synchronous throw at the call site.
  @override
  Future<Todo> call(String title) async {
    final trimmed = title.trim();

    if (trimmed.isEmpty) {
      throw const ValidationFailure(LocaleKeys.errorTodoTitleRequired);
    }
    if (trimmed.length > maxTitleLength) {
      throw ValidationFailure(
        LocaleKeys.errorTodoTitleTooLong,
        namedArgs: {'max': '$maxTitleLength'},
      );
    }

    return _repository.addTodo(trimmed);
  }
}
