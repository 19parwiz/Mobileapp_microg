import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/logger.dart';
import '../domain/user_profile.dart';
import '../domain/app_settings.dart';
import '../domain/repositories/i_profile_repository.dart';

/// Repository for managing user profile and settings persistence
class ProfileRepository implements IProfileRepository {
  final FlutterSecureStorage _secureStorage;

  ProfileRepository({
    required FlutterSecureStorage secureStorage,
  }) : _secureStorage = secureStorage;

  // Profile storage keys
  static const String _profileKey = 'user_profile';
  static const String _settingsKey = 'app_settings';

  /// Load user profile from local storage
  @override
  Future<UserProfile?> loadProfile() async {
    try {
      final profileJson = await _secureStorage.read(key: _profileKey);
      if (profileJson == null || profileJson.isEmpty) {
        AppLogger.i('No profile found in storage');
        return null;
      }

      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserProfile.fromJson(profileMap);
    } catch (e) {
      AppLogger.e('Error loading profile', e);
      return null;
    }
  }

  /// Save user profile to local storage
  @override
  Future<void> saveProfile(UserProfile profile) async {
    try {
      final profileJson = jsonEncode(profile.toJson());
      await _secureStorage.write(key: _profileKey, value: profileJson);
      AppLogger.i('Profile saved successfully');
    } catch (e) {
      AppLogger.e('Error saving profile', e);
      rethrow;
    }
  }

  /// Load app settings from local storage
  @override
  Future<AppSettings> loadSettings() async {
    try {
      final settingsJson = await _secureStorage.read(key: _settingsKey);
      if (settingsJson == null || settingsJson.isEmpty) {
        AppLogger.i('No settings found, using defaults');
        return const AppSettings();
      }

      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      return AppSettings.fromJson(settingsMap);
    } catch (e) {
      AppLogger.e('Error loading settings', e);
      return const AppSettings();
    }
  }

  /// Save app settings to local storage
  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final settingsJson = jsonEncode(settings.toJson());
      await _secureStorage.write(key: _settingsKey, value: settingsJson);
      AppLogger.i('Settings saved successfully');
    } catch (e) {
      AppLogger.e('Error saving settings', e);
      rethrow;
    }
  }

  /// Clear all profile data (for logout)
  @override
  Future<void> clearProfile() async {
    try {
      await _secureStorage.delete(key: _profileKey);
      await _secureStorage.delete(key: _settingsKey);
      AppLogger.i('Profile data cleared');
    } catch (e) {
      AppLogger.e('Error clearing profile', e);
    }
  }
}
