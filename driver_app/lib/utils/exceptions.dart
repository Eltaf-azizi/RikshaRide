/// Custom Exceptions for the app
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}

/// Authentication related exceptions
class AuthException extends AppException {
  AuthException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Firestore related exceptions
class FirestoreException extends AppException {
  FirestoreException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Network related exceptions
class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Validation related exceptions
class ValidationException extends AppException {
  ValidationException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

/// Generic app exceptions
class AppError extends AppException {
  AppError({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}
