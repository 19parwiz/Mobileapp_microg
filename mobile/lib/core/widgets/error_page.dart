import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../app/router/app_router.dart';
import 'custom_button.dart';

/// Error page widget for handling invalid routes
class ErrorPage extends StatelessWidget {
  final String? errorMessage;
  final String? routePath;

  const ErrorPage({
    super.key,
    this.errorMessage,
    this.routePath,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingXL),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppSizes.spacingXL),
              
              // Error Title
              Text(
                '404',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark 
                          ? AppColors.textOnPrimary 
                          : AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              
              // Error Message
              Text(
                'Page Not Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark 
                          ? AppColors.textOnPrimary 
                          : AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: AppSizes.spacingS),
              
              // Error Details
              if (errorMessage != null || routePath != null) ...[
                Text(
                  'The page you are looking for does not exist.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingM),
                if (routePath != null)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? AppColors.surfaceDark 
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link,
                          size: AppSizes.iconS,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: AppSizes.spacingS),
                        Text(
                          routePath!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                fontFamily: 'monospace',
                              ),
                        ),
                      ],
                    ),
                  ),
                if (errorMessage != null) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  Text(
                    errorMessage!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textHint,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ] else
                Text(
                  'The page you are looking for does not exist.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              
              const SizedBox(height: AppSizes.spacingXL),
              
              // Navigation Buttons
              CustomButton(
                text: 'Go to Home',
                style: CustomButtonStyle.primary,
                icon: Icons.home,
                onPressed: () => context.go(AppRouter.home),
              ),
              const SizedBox(height: AppSizes.spacingM),
              CustomButton(
                text: 'Go to Profile',
                style: CustomButtonStyle.secondary,
                icon: Icons.person,
                onPressed: () => context.go(AppRouter.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

