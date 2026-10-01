import 'package:flutter_core/features/todo/domain/entities/todo.dart';

/// Serialization lives here so the domain entity stays free of JSON concerns.
///
/// Written by hand instead of generated: the project deliberately avoids a
/// `build_runner` step for a four-field model. Swap in `json_serializable`
/// once the models justify it.
class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.title,
    required super.createdAt,
    super.isCompleted,
  });

  factory TodoModel.fromEntity(Todo todo) => TodoModel(
    id: todo.id,
    title: todo.title,
    createdAt: todo.createdAt,
    isCompleted: todo.isCompleted,
  );

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
    id: json['id'] as String,
    title: json['title'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    isCompleted: json['isCompleted'] as bool? ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
    'isCompleted': isCompleted,
  };
}
