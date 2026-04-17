import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/logger.dart';
import '../../../app/config/app_config.dart';
import '../domain/auth_api_exception.dart';
import '../domain/auth_model.dart';

class AuthApi {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthApi({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  AuthApiException _mapDio(DioException e, {required String fallback}) {
    final resp = e.response;
    final data = resp?.data;
    String message = fallback;
    String? errorCode;
    if (data is Map<String, dynamic>) {
      final m = data['message']?.toString();
      if (m != null && m.isNotEmpty) message = m;
      errorCode = data['errorCode']?.toString();
    }
    return AuthApiException(
      message: message,
      statusCode: resp?.statusCode,
      errorCode: errorCode,
    );
  }

  Future<AuthModel> login(String email, String password) async {
    try {
      AppLogger.d('Login request: $email');

      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final authModel = AuthModel.fromJson(data);

      if (authModel.hasUsableToken) {
        await _secureStorage.write(
          key: AppConfig.tokenKey,
          value: authModel.token!,
        );
      }

      AppLogger.i('Login successful: ${authModel.email}');
      return authModel;
    } on DioException catch (e) {
      AppLogger.e('Login error', e);
      throw _mapDio(e, fallback: 'Login failed');
    } catch (e) {
      AppLogger.e('Login error', e);
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<AuthModel> register(String email, String password, String? name) async {
    try {
      AppLogger.d('Register request: $email');

      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          if (name != null && name.isNotEmpty) 'name': name,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final authModel = AuthModel.fromJson(data);

      if (authModel.hasUsableToken) {
        await _secureStorage.write(
          key: AppConfig.tokenKey,
          value: authModel.token!,
        );
      } else {
        await _secureStorage.delete(key: AppConfig.tokenKey);
      }

      AppLogger.i('Registration response: ${authModel.email}');
      return authModel;
    } on DioException catch (e) {
      AppLogger.e('Registration error', e);
      throw _mapDio(e, fallback: 'Registration failed');
    } catch (e) {
      AppLogger.e('Registration error', e);
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post('/auth/forgot-password', data: {'email': email});
    } on DioException catch (e) {
      throw _mapDio(e, fallback: 'Request failed');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dio.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw _mapDio(e, fallback: 'Reset failed');
    }
  }

  Future<void> resendVerification(String email) async {
    try {
      await _dio.post('/auth/resend-verification', data: {'email': email});
    } on DioException catch (e) {
      throw _mapDio(e, fallback: 'Could not resend email');
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.d('Logout request');

      await _dio.post('/auth/logout');

      await _secureStorage.delete(key: AppConfig.tokenKey);
      await _secureStorage.delete(key: AppConfig.userKey);

      AppLogger.i('Logout successful');
    } catch (e) {
      AppLogger.e('Logout error', e);
      await _secureStorage.delete(key: AppConfig.tokenKey);
      await _secureStorage.delete(key: AppConfig.userKey);
    }
  }
}
