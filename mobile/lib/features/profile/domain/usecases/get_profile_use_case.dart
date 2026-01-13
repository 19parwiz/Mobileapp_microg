import '../repositories/i_profile_repository.dart';
import '../user_profile.dart';

/// One action: load the stored profile (if any).
class GetProfileUseCase {
  final IProfileRepository _profileRepository;

  GetProfileUseCase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  Future<UserProfile?> call() => _profileRepository.loadProfile();
}


