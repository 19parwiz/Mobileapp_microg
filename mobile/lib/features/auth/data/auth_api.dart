import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/logger.dart';
import '../../../app/config/app_config.dart';
import '../domain/auth_model.dart';

class AuthApi {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthApi({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

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

      if (authModel.token != null) {
        await _secureStorage.write(
          key: AppConfig.tokenKey,
          value: authModel.token!,
        );
      }

      AppLogger.i('Login successful: ${authModel.email}');
      return authModel;
    } on DioException catch (e) {
      AppLogger.e('Login error', e);
      throw Exception(_extractErrorMessage(e, fallback: 'Login failed'));
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

      if (authModel.token != null) {
        await _secureStorage.write(
          key: AppConfig.tokenKey,
          value: authModel.token!,
        );
      }

      AppLogger.i('Registration successful: ${authModel.email}');
      return authModel;
    } on DioException catch (e) {
      AppLogger.e('Registration error', e);
      throw Exception(_extractErrorMessage(e, fallback: 'Registration failed'));
    } catch (e) {
      AppLogger.e('Registration error', e);
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.d('Logout request');

      await _dio.post('/auth/logout');

      // Clear secure storage
      await _secureStorage.delete(key: AppConfig.tokenKey);
      await _secureStorage.delete(key: AppConfig.userKey);

      AppLogger.i('Logout successful');
    } catch (e) {
      AppLogger.e('Logout error', e);
      // Clear storage even if API call fails
      await _secureStorage.delete(key: AppConfig.tokenKey);
      await _secureStorage.delete(key: AppConfig.userKey);
    }
  }

  String _extractErrorMessage(DioException error, {required String fallback}) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return message;
      }
    }
    return fallback;
  }
}

