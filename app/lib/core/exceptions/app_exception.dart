/// Exceptions thrown by the data layer (remote/local data sources).
/// Repositories catch these and translate them into [Failure]s for the
/// domain layer, so nothing above the repository boundary ever touches
/// a raw exception type.
sealed class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, this.statusCode});

  final int? statusCode;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Failed to read local cache']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired, please log in again'])
      : super(code: 'UNAUTHORIZED');
}

class ValidationException extends AppException {
  const ValidationException(super.message, {this.fieldErrors}) : super(code: 'VALIDATION_ERROR');

  final Map<String, String>? fieldErrors;
}

class PermissionException extends AppException {
  const PermissionException(super.message) : super(code: 'PERMISSION_DENIED');
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong']);
}
