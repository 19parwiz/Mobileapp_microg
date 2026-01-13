import '../auth_model.dart';
import '../repositories/i_auth_repository.dart';

/// One action: login with email+password.
class LoginUseCase {
  final IAuthRepository _authRepository;

  LoginUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<AuthModel> call({
    required String email,
    required String password,
  }) {
    return _authRepository.login(email, password);
  }
}


