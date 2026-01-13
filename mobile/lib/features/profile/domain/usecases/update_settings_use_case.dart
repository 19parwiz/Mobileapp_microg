import '../app_settings.dart';
import '../repositories/i_profile_repository.dart';

/// One action: update (and persist) app settings.
class UpdateSettingsUseCase {
  final IProfileRepository _profileRepository;

  UpdateSettingsUseCase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  Future<void> call(AppSettings settings) => _profileRepository.saveSettings(settings);
}


