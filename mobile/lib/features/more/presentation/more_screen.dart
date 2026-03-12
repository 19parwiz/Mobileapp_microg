import 'package:flutter/material.dart';

import '../../../app/di/injector.dart';
import '../../../app/theme/theme_provider.dart';
import '../../../app/router/app_router.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/responsive_constrained.dart';
import 'package:provider/provider.dart';
import '../../auth/domain/usecases/get_current_user_use_case.dart';

/// Placeholder "More" screen for additional options and info.
class MoreScreen extends StatefulWidget {
  /// Whether to show AppBar (for standalone routes) or not (for MainScaffold tabs)
  final bool showAppBar;

  const MoreScreen({super.key, this.showAppBar = false});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final user = await getIt<GetCurrentUserUseCase>()();
    if (!mounted) return;
    setState(() {
      _isAdmin = (user?.role ?? '').toUpperCase() == 'ADMIN';
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget content = Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final isDark = themeProvider.isDarkMode;

        return SafeArea(
            child: ResponsiveConstrained(
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
                if (_isAdmin) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Admin Panel'),
                    subtitle: const Text('Manage users and all devices'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push(AppRouter.admin);
                    },
                  ),
                ],
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
    
    // If showAppBar is true (standalone route), wrap in Scaffold with AppBar
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('More'),
        ),
        body: content,
      );
    }

    // If embedded in MainScaffold (showAppBar = false), return just the content (no Scaffold)
    return content;
  }
}
