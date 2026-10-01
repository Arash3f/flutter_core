import 'package:flutter_core/core/error/failure.dart';
import 'package:flutter_core/core/utils/l10n/locale_keys.g.dart';
import 'package:flutter_core/features/todo/domain/entities/todo.dart';
import 'package:flutter_core/features/todo/domain/repositories/todo_repository.dart';
import 'package:flutter_core/features/todo/domain/usecases/add_todo.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeTodoRepository implements TodoRepository {
  final List<String> added = [];

  @override
  Future<Todo> addTodo(String title) async {
    added.add(title);
    return Todo(id: '1', title: title, createdAt: DateTime(2026));
  }

  @override
  Future<void> deleteTodo(String id) => throw UnimplementedError();

  @override
  Future<List<Todo>> getTodos() => throw UnimplementedError();

  @override
  Future<Todo> toggleTodo(String id) => throw UnimplementedError();
}

void main() {
  late _FakeTodoRepository repository;
  late AddTodo addTodo;

  setUp(() {
    repository = _FakeTodoRepository();
    addTodo = AddTodo(repository);
  });

  test('trims the title before saving', () async {
    final todo = await addTodo('  Buy milk  ');

    expect(todo.title, 'Buy milk');
    expect(repository.added, ['Buy milk']);
  });

  test('rejects an empty title without touching the repository', () async {
    await expectLater(
      addTodo('   '),
      throwsA(const ValidationFailure(LocaleKeys.errorTodoTitleRequired)),
    );
    expect(repository.added, isEmpty);
  });

  test('rejects a title longer than the limit', () async {
    await expectLater(
      addTodo('x' * (AddTodo.maxTitleLength + 1)),
      throwsA(isA<ValidationFailure>()),
    );
  });
}
