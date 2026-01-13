import '../repositories/i_auth_repository.dart';

/// One action: get the current auth token (if present).
class GetTokenUseCase {
  final IAuthRepository _authRepository;

  GetTokenUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<String?> call() => _authRepository.getToken();
}


