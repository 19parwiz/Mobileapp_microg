import '../auth_model.dart';
import '../repositories/i_auth_repository.dart';

/// One action: register a new user.
class RegisterUseCase {
  final IAuthRepository _authRepository;

  RegisterUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<AuthModel> call({
    required String email,
    required String password,
    String? name,
  }) {
    return _authRepository.register(email, password, name);
  }
}


