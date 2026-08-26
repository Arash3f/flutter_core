import 'dart:convert';

import 'package:flutter_core/core/error/exceptions.dart';
import 'package:flutter_core/core/utils/local_storage/shared_preferences/shared_preferences.dart';
import 'package:flutter_core/features/todo/data/models/todo_model.dart';

abstract interface class TodoLocalDataSource {
  Future<List<TodoModel>> readAll();

  Future<void> writeAll(List<TodoModel> todos);
}

/// Backed by `SharedPreferences`. Swapping this for sqflite, Hive, or a REST
/// data source touches only this file plus the provider that constructs it.
class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  const TodoLocalDataSourceImpl();

  @override
  Future<List<TodoModel>> readAll() async {
    try {
      final raw = SharedPrefs.readData<List<String>>(SharedPrefs.todos) ?? [];

      return raw
          .map((entry) => jsonDecode(entry) as Map<String, dynamic>)
          .map(TodoModel.fromJson)
          .toList();
    } on Exception catch (error) {
      throw CacheException('Stored todos could not be decoded: $error');
    }
  }

  @override
  Future<void> writeAll(List<TodoModel> todos) async {
    final raw = todos.map((todo) => jsonEncode(todo.toJson())).toList();

    final saved = await SharedPrefs.saveData(SharedPrefs.todos, raw);
    if (!saved) {
      throw const CacheException('Todos could not be written to disk.');
    }
  }
}
