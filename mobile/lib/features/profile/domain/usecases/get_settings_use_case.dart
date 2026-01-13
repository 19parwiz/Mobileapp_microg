import '../app_settings.dart';
import '../repositories/i_profile_repository.dart';

/// One action: load persisted app settings.
class GetSettingsUseCase {
  final IProfileRepository _profileRepository;

  GetSettingsUseCase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  Future<AppSettings> call() => _profileRepository.loadSettings();
}


