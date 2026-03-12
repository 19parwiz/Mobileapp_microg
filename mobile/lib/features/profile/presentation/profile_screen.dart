import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/responsive_constrained.dart';
import '../../../app/router/app_router.dart';
import '../../../app/di/injector.dart';
import '../../auth/domain/usecases/logout_use_case.dart';
import '../domain/usecases/clear_profile_use_case.dart';
import 'profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.signOut),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final logoutUseCase = getIt<LogoutUseCase>();
        final clearProfileUseCase = getIt<ClearProfileUseCase>();
        
        await logoutUseCase();
        await clearProfileUseCase();
        
        if (context.mounted) {
          context.go(AppRouter.home);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.go(AppRouter.home),
        ),
        title: const Text(AppStrings.profile),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = provider.profile;
          final displayName = profile?.name ?? 'User';
          final displayEmail = profile?.email ?? 'user@example.com';

          return SafeArea(
            child: ResponsiveConstrained(
              child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                children: [
                  // Avatar section - editable
                  GestureDetector(
                    onTap: () {
                      context.push(AppRouter.editProfile);
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primary,
                          backgroundImage: profile?.avatarUrl != null
                              ? NetworkImage(profile!.avatarUrl!)
                              : null,
                          child: profile?.avatarUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.textOnPrimary,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 20,
                              color: AppColors.textOnPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  
                  // Name - editable
                  Text(
                    displayName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: AppSizes.spacingS),
                  
                  // Email - editable
                  Text(
                    displayEmail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSizes.spacingXL),
                  
                  // Action cards with rounded corners
                  Card(
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingL,
                            vertical: AppSizes.paddingS,
                          ),
                          leading: const Icon(Icons.edit),
                          title: Text(
                            AppStrings.editProfile,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push(AppRouter.editProfile);
                          },
                        ),
                        const Divider(height: 1),
                        // Settings moved to More screen for cleaner layout
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXL),
                  
                  // Logout button with rounded corners
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout),
                      label: const Text(
                        AppStrings.signOut,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingL,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                        ),
                        minimumSize: const Size(double.infinity, AppSizes.buttonHeightL),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ),
              ),
            ),
          );
        },
      ),
    );
  }
}
