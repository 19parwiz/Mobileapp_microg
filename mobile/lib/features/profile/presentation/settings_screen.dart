import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import 'profile_provider.dart';

/// Settings screen with theme toggle, notifications, and language options
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Get display name for language code
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fa':
        return 'فارسی (Farsi)';
      case 'kk':
        return 'Қазақша (Kazakh)';
      case 'ru':
        return 'Русский (Russian)';
      default:
        return languageCode;
    }
  }

  /// Build language option list tile
  Widget _buildLanguageOption(
    BuildContext context,
    ProfileProvider provider,
    String languageCode,
    String languageName,
  ) {
    final isSelected = provider.settings.language == languageCode;
    return InkWell(
      onTap: () {
        provider.updateSettings(
          provider.settings.copyWith(language: languageCode),
        );
        Navigator.of(context).pop();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : null,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.go(AppRouter.home),
        ),
        title: const Text('Settings'),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.settings.language.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              children: [
            // Theme section
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Card(
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              ),
              child: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return ListTile(
                    leading: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark Mode'),
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
              'Notifications',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                return Card(
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.notifications_active),
                        title: const Text('Enable Notifications'),
                        trailing: Switch(
                          value: provider.settings.notificationsEnabled,
                          activeThumbColor: AppColors.primary,
                          onChanged: (value) {
                            provider.updateSettings(
                              provider.settings.copyWith(
                                notificationsEnabled: value,
                              ),
                            );
                          },
                        ),
                      ),
                      if (provider.settings.notificationsEnabled) ...[
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email),
                          title: const Text('Email Notifications'),
                          trailing: Switch(
                            value: provider.settings.emailNotifications,
                            activeThumbColor: AppColors.primary,
                            onChanged: (value) {
                              provider.updateSettings(
                                provider.settings.copyWith(
                                  emailNotifications: value,
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.notifications),
                          title: const Text('Push Notifications'),
                          trailing: Switch(
                            value: provider.settings.pushNotifications,
                            activeThumbColor: AppColors.primary,
                            onChanged: (value) {
                              provider.updateSettings(
                                provider.settings.copyWith(
                                  pushNotifications: value,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.spacingXL),

            // Preferences section
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                // Ensure settings are loaded with fallback
                final currentLanguage = provider.settings.language.isEmpty
                    ? 'en'
                    : provider.settings.language;
                final languageName = _getLanguageName(currentLanguage);

                return Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Language'),
                        subtitle: Text(languageName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // Language selection dialog
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Select Language'),
                              contentPadding: EdgeInsets.zero,
                              content: Container(
                                constraints: const BoxConstraints(
                                  maxHeight: 300,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildLanguageOption(
                                        dialogContext,
                                        provider,
                                        'en',
                                        'English',
                                      ),
                                      const Divider(height: 1),
                                      _buildLanguageOption(
                                        dialogContext,
                                        provider,
                                        'fa',
                                        'فارسی (Farsi)',
                                      ),
                                      const Divider(height: 1),
                                      _buildLanguageOption(
                                        dialogContext,
                                        provider,
                                        'kk',
                                        'Қазақша (Kazakh)',
                                      ),
                                      const Divider(height: 1),
                                      _buildLanguageOption(
                                        dialogContext,
                                        provider,
                                        'ru',
                                        'Русский (Russian)',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.thermostat),
                        title: const Text('Temperature Unit'),
                        subtitle: Text(provider.settings.temperatureUnit == 'C'
                            ? 'Celsius (°C)'
                            : 'Fahrenheit (°F)'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          provider.updateSettings(
                            provider.settings.copyWith(
                              temperatureUnit: provider.settings.temperatureUnit == 'C'
                                  ? 'F'
                                  : 'C',
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.refresh),
                        title: const Text('Auto Refresh'),
                        subtitle: const Text('Automatically refresh sensor data'),
                        trailing: Switch(
                          value: provider.settings.autoRefresh,
                          activeThumbColor: AppColors.primary,
                          onChanged: (value) {
                            provider.updateSettings(
                              provider.settings.copyWith(autoRefresh: value),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
              ],
            ),
          );
        },
      ),
    );
  }
}
