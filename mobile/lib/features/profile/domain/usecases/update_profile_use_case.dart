import '../repositories/i_profile_repository.dart';
import '../user_profile.dart';

/// One action: update (and persist) the user's profile.
///
/// Keeps profile mutation logic out of presentation.
class UpdateProfileUseCase {
  final IProfileRepository _profileRepository;

  UpdateProfileUseCase({required IProfileRepository profileRepository})
      : _profileRepository = profileRepository;

  Future<UserProfile> call({
    required UserProfile? currentProfile,
    String? name,
    String? email,
    String? avatarUrl,
    String? phoneNumber,
  }) async {
    final now = DateTime.now();

    final updatedProfile = currentProfile?.copyWith(
          name: name,
          email: email,
          avatarUrl: avatarUrl,
          phoneNumber: phoneNumber,
          updatedAt: now,
        ) ??
        UserProfile(
          id: '1',
          email: email ?? 'user@example.com',
          name: name,
          avatarUrl: avatarUrl,
          phoneNumber: phoneNumber,
          createdAt: now,
          updatedAt: now,
        );

    await _profileRepository.saveProfile(updatedProfile);
    return updatedProfile;
  }
}


