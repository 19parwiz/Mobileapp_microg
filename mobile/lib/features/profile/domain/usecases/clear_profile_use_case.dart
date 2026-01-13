import '../repositories/i_profile_repository.dart';

/// One action: clear profile + settings from local storage.
class ClearProfileUseCase {
  final IProfileRepository _profileRepository;

  ClearProfileUseCase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  Future<void> call() => _profileRepository.clearProfile();
}


