import 'package:flutter/material.dart';
import 'app_localization.dart';

/// Localization Provider for managing app-wide language preferences
/// Notifies listeners when language changes
class LocalizationProvider with ChangeNotifier {
  String _currentLanguage = 'en';

  String get currentLanguage => _currentLanguage;

  /// Get current localization strings
  AppLocalization get strings => LocalizationService.currentLocalization;

  /// Get all supported language codes
  List<String> get supportedLanguages => LocalizationService.supportedLanguages;

  /// Change app language
  /// Updates LocalizationService and notifies all listeners
  void setLanguage(String languageCode) {
    if (!LocalizationService.supportedLanguages.contains(languageCode)) {
      return; // Invalid language code
    }

    _currentLanguage = languageCode;
    LocalizationService.setLocalization(languageCode);
    notifyListeners();
  }

  /// Initialize language from stored preference
  /// Called during app startup
  void initializeLanguage(String savedLanguage) {
    if (LocalizationService.supportedLanguages.contains(savedLanguage)) {
      _currentLanguage = savedLanguage;
      LocalizationService.setLocalization(savedLanguage);
    } else {
      // Default to English if saved language is invalid
      _currentLanguage = 'en';
      LocalizationService.setLocalization('en');
    }
  }
}
