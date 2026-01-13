import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// Loading skeleton for sensor cards with shimmer effect
class SensorCardSkeleton extends StatelessWidget {
  const SensorCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(AppSizes.radiusL),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon skeleton
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.border.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  // Title skeleton
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.border.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingXS),
                        Container(
                          width: 180,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.border.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingL),
              // Value skeleton
              Container(
                width: 100,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
