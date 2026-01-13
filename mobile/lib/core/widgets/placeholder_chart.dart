import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Placeholder chart widget for displaying sensor data visualization
class PlaceholderChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const PlaceholderChart({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor = isDark ? AppColors.surfaceDark : AppColors.surface;

    return Card(
      color: cardBackgroundColor,
      elevation: onTap != null ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark 
                                  ? AppColors.textOnPrimary 
                                  : AppColors.textPrimary,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSizes.spacingXS),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ],
                  ),
                  Icon(
                    Icons.show_chart,
                    color: AppColors.primary,
                    size: AppSizes.iconL,
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingL),
              // Placeholder chart area
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: AppSizes.iconXL,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                      Text(
                        'Chart will be displayed here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textHint,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                      const SizedBox(height: AppSizes.spacingXS),
                      Text(
                        'Sensor data visualization',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textHint,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

