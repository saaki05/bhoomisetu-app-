import 'package:freezed_annotation/freezed_annotation.dart';

import 'app_exception.dart';

part 'failure.freezed.dart';

/// Domain-layer representation of "why a use case failed". Use cases and
/// repositories return `Either<Failure, T>` (via dartz) instead of throwing,
/// so the presentation layer can exhaustively pattern-match every outcome.
@freezed
sealed class Failure with _$Failure {
  const factory Failure.server(String message, {int? statusCode, String? code}) = ServerFailure;
  const factory Failure.network([@Default('No internet connection') String message]) = NetworkFailure;
  const factory Failure.cache([@Default('Failed to read local data') String message]) = CacheFailure;
  const factory Failure.unauthorized([@Default('Session expired, please log in again') String message]) =
      UnauthorizedFailure;
  const factory Failure.validation(String message, {Map<String, String>? fieldErrors}) = ValidationFailure;
  const factory Failure.permission(String message) = PermissionFailure;
  const factory Failure.unknown([@Default('Something went wrong') String message]) = UnknownFailure;
}

extension FailureMessage on Failure {
  /// The user-facing message every [Failure] variant already carries —
  /// avoids a `.map(...)` block at every call site that just wants text
  /// for a snackbar.
  String get message => switch (this) {
        ServerFailure(:final message) => message,
        NetworkFailure(:final message) => message,
        CacheFailure(:final message) => message,
        UnauthorizedFailure(:final message) => message,
        ValidationFailure(:final message) => message,
        PermissionFailure(:final message) => message,
        UnknownFailure(:final message) => message,
      };
}

/// Maps a data-layer [AppException] to the corresponding domain [Failure].
/// Repository implementations call this from their catch blocks so callers
/// never need to know about the exception hierarchy.
Failure failureFromException(AppException exception) {
  return switch (exception) {
    ServerException(:final message, :final statusCode, :final code) =>
      Failure.server(message, statusCode: statusCode, code: code),
    NetworkException(:final message) => Failure.network(message),
    CacheException(:final message) => Failure.cache(message),
    UnauthorizedException(:final message) => Failure.unauthorized(message),
    ValidationException(:final message, :final fieldErrors) =>
      Failure.validation(message, fieldErrors: fieldErrors),
    PermissionException(:final message) => Failure.permission(message),
    UnknownException(:final message) => Failure.unknown(message),
  };
}
