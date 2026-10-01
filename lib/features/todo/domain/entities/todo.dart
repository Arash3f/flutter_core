import 'package:equatable/equatable.dart';

/// Pure domain object: no JSON, no framework, no storage details.
class Todo extends Equatable {
  const Todo({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final bool isCompleted;

  Todo copyWith({String? title, bool? isCompleted}) => Todo(
    id: id,
    title: title ?? this.title,
    createdAt: createdAt,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Todo toggled() => copyWith(isCompleted: !isCompleted);

  @override
  List<Object?> get props => [id, title, createdAt, isCompleted];
}
