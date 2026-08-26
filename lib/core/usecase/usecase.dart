/// A single piece of business logic, callable like a function.
///
/// ```dart
/// final todos = await getTodos(const NoParams());
/// ```
abstract interface class UseCase<Output, Input> {
  Future<Output> call(Input input);
}

/// Placeholder for use cases that take no input.
class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => other is NoParams;

  @override
  int get hashCode => 0;
}
