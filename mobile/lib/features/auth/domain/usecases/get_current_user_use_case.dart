import '../auth_model.dart';
import '../repositories/i_auth_repository.dart';

class GetCurrentUserUseCase {
  final IAuthRepository _authRepository;

  GetCurrentUserUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<AuthModel?> call() => _authRepository.getCurrentUser();
}
