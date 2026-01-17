import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import 'profile_provider.dart';

/// Simple Settings screen without complex dialogs
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
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
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
                      ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Card(
                  child: Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
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
                      ),
                ),
                const SizedBox(height: AppSizes.spacingM),
                Card(
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
                    ],
                  ),
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
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.language),
                        title: const Text('Language'),
                        subtitle: Text(
                          provider.settings.language.isEmpty
                              ? 'English'
                              : provider.settings.language,
                        ),
                        onTap: () {
                          // Simple toggle between en and fa
                          final newLang =
                              provider.settings.language == 'en' ? 'fa' : 'en';
                          provider.updateSettings(
                            provider.settings.copyWith(language: newLang),
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
                        onTap: () {
                          provider.updateSettings(
                            provider.settings.copyWith(
                              temperatureUnit:
                                  provider.settings.temperatureUnit == 'C'
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
                        subtitle: const Text(
                            'Automatically refresh sensor data'),
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
