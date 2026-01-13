import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/logger.dart';
import '../../../app/config/app_config.dart';
import '../domain/auth_model.dart';

class AuthApi {
  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;

  AuthApi({
    required http.Client httpClient,
    required FlutterSecureStorage secureStorage,
  })  : _httpClient = httpClient,
        _secureStorage = secureStorage;

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }

  Future<AuthModel> login(String email, String password) async {
    try {
      AppLogger.d('Login request: $email');
      
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authModel = AuthModel.fromJson(data);
        
        // Store token securely
        if (authModel.token != null) {
          await _secureStorage.write(
            key: AppConfig.tokenKey,
            value: authModel.token!,
          );
        }
        
        AppLogger.i('Login successful: ${authModel.email}');
        return authModel;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      AppLogger.e('Login error', e);
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<AuthModel> register(String email, String password, String? name) async {
    try {
      AppLogger.d('Register request: $email');
      
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        }),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authModel = AuthModel.fromJson(data);
        
        // Store token securely
        if (authModel.token != null) {
          await _secureStorage.write(
            key: AppConfig.tokenKey,
            value: authModel.token!,
          );
        }
        
        AppLogger.i('Registration successful: ${authModel.email}');
        return authModel;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      AppLogger.e('Registration error', e);
      if (e is Exception) rethrow;
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.d('Logout request');
      
      final token = await _getToken();
      if (token != null) {
        await _httpClient.post(
          Uri.parse('${AppConfig.baseUrl}/auth/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(AppConfig.apiTimeout);
      }
      
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
}

