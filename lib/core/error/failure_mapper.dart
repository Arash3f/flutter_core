import 'package:flutter_core/core/error/exceptions.dart';
import 'package:flutter_core/core/error/failure.dart';

/// Translates data-source [Exception]s into domain [Failure]s.
///
/// Repositories should call this at their boundary so presentation only ever
/// sees [Failure]. When Dio (or similar) is added, map its errors onto
/// [NetworkException] / [ServerException] in the data source, then let this
/// mapper finish the job.
abstract final class FailureMapper {
  /// Returns a [Failure] for [error]. Already-domain errors pass through.
  static Failure map(Object error) {
    if (error is Failure) return error;

    if (error is CacheException) {
      return const CacheFailure();
    }
    if (error is NetworkException) {
      return const NetworkFailure();
    }
    if (error is ServerException) {
      return ServerFailure(statusCode: error.statusCode);
    }

    return const UnexpectedFailure();
  }

  /// Convenience for `catch` blocks that should always rethrow a [Failure].
  static Never mapAndThrow(Object error) => throw map(error);
}
