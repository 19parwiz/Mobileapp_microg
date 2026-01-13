import '../repositories/i_auth_repository.dart';

/// One action: logout the current user.
class LogoutUseCase {
  final IAuthRepository _authRepository;

  LogoutUseCase({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  Future<void> call() => _authRepository.logout();
}


