import 'package:dio/dio.dart';

/// Parses Spring [ErrorResponse]-style JSON bodies so users never see raw Dio text.
String userFacingMessageFromDio(
  DioException e, {
  String fallback = 'Something went wrong. Please try again.',
}) {
  final data = e.response?.data;
  if (data is Map) {
    final msg = data['message'];
    if (msg is String && msg.trim().isNotEmpty) {
      return msg.trim();
    }
    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final first = errors.values.first;
      if (first != null && first.toString().trim().isNotEmpty) {
        return first.toString().trim();
      }
    }
  }
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return 'Request timed out. Check your connection.';
    case DioExceptionType.connectionError:
      return 'Could not reach the server. Check your network.';
    default:
      return fallback;
  }
}
