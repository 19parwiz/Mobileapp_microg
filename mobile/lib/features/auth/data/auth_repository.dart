import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/logger.dart';
import '../../../app/config/app_config.dart';
import '../domain/auth_model.dart';
import '../domain/repositories/i_auth_repository.dart';
import 'auth_api.dart';

class AuthRepository implements IAuthRepository {
  final AuthApi _authApi;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required AuthApi authApi,
    required FlutterSecureStorage secureStorage,
  })  : _authApi = authApi,
        _secureStorage = secureStorage;

  @override
  Future<AuthModel> login(String email, String password) async {
    try {
      final authModel = await _authApi.login(email, password);
      
      // Store user data
      await _secureStorage.write(
        key: AppConfig.userKey,
        value: authModel.toJson().toString(),
      );
      
      AppLogger.i('User logged in successfully');
      return authModel;
    } catch (e) {
      AppLogger.e('Login repository error', e);
      rethrow;
    }
  }

  @override
  Future<AuthModel> register(String email, String password, String? name) async {
    try {
      final authModel = await _authApi.register(email, password, name);
      
      // Store user data
      await _secureStorage.write(
        key: AppConfig.userKey,
        value: authModel.toJson().toString(),
      );
      
      AppLogger.i('User registered successfully');
      return authModel;
    } catch (e) {
      AppLogger.e('Registration repository error', e);
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _authApi.logout();
      AppLogger.i('User logged out');
    } catch (e) {
      AppLogger.e('Logout repository error', e);
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: AppConfig.tokenKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }
}

