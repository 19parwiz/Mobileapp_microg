import '../auth_model.dart';

/// Domain abstraction for authentication.
///
/// Data layer must implement this and handle API/local storage concerns.
abstract class IAuthRepository {
  Future<AuthModel> login(String email, String password);
  Future<AuthModel> register(String email, String password, String? name);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword({required String token, required String newPassword});
  Future<void> resendVerification(String email);

  Future<bool> isLoggedIn();
  Future<String?> getToken();
  Future<AuthModel?> getCurrentUser();
}


