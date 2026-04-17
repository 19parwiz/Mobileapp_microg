/// Thrown when the auth API returns a structured error (e.g. email not verified).
class AuthApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  AuthApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  @override
  String toString() => message;
}
