import 'package:flutter/material.dart';

import '../../../app/theme/theme_provider.dart';
import '../../../app/router/app_router.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import 'package:provider/provider.dart';

/// Placeholder "More" screen for additional options and info.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          appBar: AppBar(
            title: const Text('More'),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              children: [
                ListTile(
                  leading: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Mode'),
                  subtitle: Text(isDark ? 'Dark theme is enabled' : 'Light theme is enabled'),
                  trailing: Switch(
                    value: isDark,
                    activeThumbColor: AppColors.primary,
                    onChanged: (value) {
                      themeProvider.toggleDarkMode(value);
                    },
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.account_circle_outlined),
                  title: const Text('Profile & Account'),
                  subtitle: const Text('View and manage your account details'),
                  onTap: () {
                    context.push(AppRouter.profile);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  subtitle: const Text('App preferences and options'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push(AppRouter.settings);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.devices),
                  title: const Text('My Devices'),
                  subtitle: const Text('Manage your IoT devices'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push(AppRouter.devices);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About App'),
                  subtitle: const Text('Learn more about your microgreens assistant'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('About screen coming soon')),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy & Terms'),
                  subtitle: const Text('Read about data usage and policies'),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy details coming soon')),
                    );
                  },
                ),
                const SizedBox(height: AppSizes.spacingL),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('More options coming soon')),
                      );
                    },
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      'More options',
                      style: textTheme.labelLarge?.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
