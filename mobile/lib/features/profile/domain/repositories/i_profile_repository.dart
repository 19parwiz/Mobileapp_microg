import '../app_settings.dart';
import '../user_profile.dart';

/// Domain abstraction for persisting profile + settings.
abstract class IProfileRepository {
  Future<UserProfile?> loadProfile();
  Future<void> saveProfile(UserProfile profile);

  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);

  Future<void> clearProfile();
}


