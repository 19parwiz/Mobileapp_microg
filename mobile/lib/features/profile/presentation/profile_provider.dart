import 'package:flutter/foundation.dart';
import '../domain/user_profile.dart';
import '../domain/app_settings.dart';
import '../../auth/domain/usecases/get_token_use_case.dart';
import '../domain/usecases/get_profile_use_case.dart';
import '../domain/usecases/get_settings_use_case.dart';
import '../domain/usecases/update_profile_use_case.dart';
import '../domain/usecases/update_settings_use_case.dart';

/// Provider for managing profile state
class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase _getProfileUseCase;
  final GetSettingsUseCase _getSettingsUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final UpdateSettingsUseCase _updateSettingsUseCase;
  final GetTokenUseCase _getTokenUseCase;

  UserProfile? _profile;
  AppSettings _settings = const AppSettings();
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  ProfileProvider({
    required GetProfileUseCase getProfileUseCase,
    required GetSettingsUseCase getSettingsUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required UpdateSettingsUseCase updateSettingsUseCase,
    required GetTokenUseCase getTokenUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _getSettingsUseCase = getSettingsUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _updateSettingsUseCase = updateSettingsUseCase,
        _getTokenUseCase = getTokenUseCase {
    _initializeProfile();
  }

  /// Initialize profile from storage or auth data
  Future<void> _initializeProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from profile storage
      _profile = await _getProfileUseCase();

      // If no profile, try to create from auth data
      if (_profile == null) {
        final userData = await _getTokenUseCase();
        if (userData != null) {
          // Create default profile from auth (if available)
          _profile = const UserProfile(
            id: '1',
            email: 'user@example.com',
            name: 'User',
          );
        }
      }

      // Load settings
      _settings = await _getSettingsUseCase();

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load profile: $e';
      debugPrint('Error initializing profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? avatarUrl,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _updateProfileUseCase(
        currentProfile: _profile,
        name: name,
        email: email,
        avatarUrl: avatarUrl,
        phoneNumber: phoneNumber,
      );
      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update app settings
  Future<bool> updateSettings(AppSettings newSettings) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _updateSettingsUseCase(newSettings);
      _settings = newSettings;
      _errorMessage = null;

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update settings: $e';
      debugPrint('Error updating settings: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await _initializeProfile();
  }
}
