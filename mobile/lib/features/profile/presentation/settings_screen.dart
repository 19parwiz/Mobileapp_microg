import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/l10n/localization_provider.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/widgets/responsive_constrained.dart';
import 'profile_provider.dart';

/// Settings screen with language support for English, Farsi, Kazakh, and Russian
/// 
/// LANGUAGE SUPPORT ADDED:
/// - English (en)
/// - Farsi (fa)
/// - Kazakh (kk)
/// - Russian (ru)
///
/// The language preference is:
/// 1. Stored in app settings (via ProfileProvider)
/// 2. Managed by LocalizationProvider for app-wide access
/// 3. Can be changed through the language selection dialog
///
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            tooltip: 'Go back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        title: const Text('Settings'),
      ),
      body: Consumer2<ProfileProvider, LocalizationProvider>(
        builder: (context, profileProvider, localizationProvider, child) {
          final strings = localizationProvider.strings;

          return SafeArea(
            child: ResponsiveConstrained(
              child: ListView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              children: [
                // Theme section
                Text(
                  strings.appearance,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Card(
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return ListTile(
                        leading: const Icon(Icons.dark_mode_outlined),
                        title: Text(strings.darkMode),
                        subtitle: Text(
                          themeProvider.isDarkMode
                              ? 'Dark theme is enabled'
                              : 'Light theme is enabled',
                        ),
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          activeThumbColor: AppColors.primary,
                          onChanged: (value) {
                            themeProvider.toggleDarkMode(value);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXL),
                
                // Notifications section
                Text(
                  strings.notifications,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_active),
                        title: Text(strings.enableNotifications),
                        trailing: Switch(
                          value: profileProvider.settings.notificationsEnabled,
                          activeThumbColor: AppColors.primary,
                          onChanged: (value) {
                            profileProvider.updateSettings(
                              profileProvider.settings.copyWith(
                                notificationsEnabled: value,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXL),
                
                // Preferences section
                Text(
                  strings.preferences,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Card(
                  child: Column(
                    children: [
                      /// LANGUAGE SELECTION TILE
                      /// Allows users to select from 4 supported languages
                      /// Tapping opens a dialog to choose the language
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: Text(strings.language),
                        subtitle: Text(
                          LocalizationService.getLanguageName(
                            profileProvider.settings.language,
                          ),
                        ),
                        onTap: () => _showLanguageDialog(
                          context,
                          profileProvider,
                          localizationProvider,
                          strings,
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.thermostat),
                        title: Text(strings.temperatureUnit),
                        subtitle: Text(profileProvider.settings.temperatureUnit == 'C'
                            ? 'Celsius (°C)'
                            : 'Fahrenheit (°F)'),
                        onTap: () {
                          profileProvider.updateSettings(
                            profileProvider.settings.copyWith(
                              temperatureUnit:
                                  profileProvider.settings.temperatureUnit == 'C'
                                      ? 'F'
                                      : 'C',
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: Text(strings.autoRefresh),
                        subtitle: Text(strings.autoRefreshDescription),
                        trailing: Switch(
                          value: profileProvider.settings.autoRefresh,
                          activeThumbColor: AppColors.primary,
                          onChanged: (value) {
                            profileProvider.updateSettings(
                              profileProvider.settings.copyWith(autoRefresh: value),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Show language selection dialog
  /// 
  /// LANGUAGE SUPPORT:
  /// - Displays all 4 supported languages (en, fa, kk, ru)
  /// - Updates both ProfileProvider (for persistence) and LocalizationProvider (for app-wide access)
  /// - Dialog shows selected language with a checkmark
  /// - Closes automatically after selection
  void _showLanguageDialog(
    BuildContext context,
    ProfileProvider profileProvider,
    LocalizationProvider localizationProvider,
    AppLocalization strings,
  ) {
    final languages = [
      ('en', strings.english),
      ('fa', strings.farsi),
      ('kk', strings.kazakh),
      ('ru', strings.russian),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.language),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final (code, name) = languages[index];
              final isSelected = profileProvider.settings.language == code;

              return ListTile(
                title: Text(name),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                selected: isSelected,
                selectedTileColor: AppColors.primary.withOpacity(0.1),
                onTap: () {
                  // Update language in profile settings
                  profileProvider.updateSettings(
                    profileProvider.settings.copyWith(language: code),
                  );
                  // Update localization provider for app-wide use
                  localizationProvider.setLanguage(code);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.cancel),
          ),
        ],
      ),
    );
  }
}

