import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/Plant.dart';

/// Beautiful plant card widget displaying plant information
class PlantCard extends StatelessWidget {
  final Plant plant;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const PlantCard({
    super.key,
    required this.plant,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  Color _getHealthColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'healthy':
        return AppColors.success;
      case 'needs water':
        return Colors.orange;
      case 'warning':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getGrowthStageColor(String stage) {
    switch (stage.toLowerCase()) {
      case 'ready to harvest':
        return AppColors.success;
      case 'growing':
        return AppColors.primary;
      case 'seedling':
        return Colors.blue;
      case 'harvested':
        return AppColors.textSecondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSizes.spacingM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon, name, and actions
              Row(
                children: [
                  // Plant icon/emoji
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Center(
                      child: Text(
                        plant.iconEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSizes.spacingM),
                  // Plant name and type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                        SizedBox(height: AppSizes.spacingXS),
                        Text(
                          plant.type,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  if (onEdit != null)
                    IconButton(
                      icon: Icon(Icons.edit, color: AppColors.primary),
                      onPressed: onEdit,
                      tooltip: 'Edit plant',
                    ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: onDelete,
                      tooltip: 'Delete plant',
                    ),
                ],
              ),
              SizedBox(height: AppSizes.spacingM),
              
              // Description
              if (plant.description != null && plant.description!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.spacingS),
                  child: Text(
                    plant.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              // Growth stage and health status badges
              Wrap(
                spacing: AppSizes.spacingS,
                runSpacing: AppSizes.spacingS,
                children: [
                  // Growth stage badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _getGrowthStageColor(plant.growthStage).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color: _getGrowthStageColor(plant.growthStage).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      plant.growthStage,
                      style: TextStyle(
                        color: _getGrowthStageColor(plant.growthStage),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  // Health status badge
                  if (plant.healthStatus != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingM,
                        vertical: AppSizes.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: _getHealthColor(plant.healthStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: _getHealthColor(plant.healthStatus).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            plant.healthStatus?.toLowerCase() == 'healthy'
                                ? Icons.check_circle
                                : Icons.warning,
                            size: 14,
                            color: _getHealthColor(plant.healthStatus),
                          ),
                          SizedBox(width: AppSizes.spacingXS),
                          Text(
                            plant.healthStatus!,
                            style: TextStyle(
                              color: _getHealthColor(plant.healthStatus),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: AppSizes.spacingM),
              
              // Days since planting
              if (plant.daysSincePlanting != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: AppSizes.spacingXS),
                    Text(
                      'Planted ${plant.daysSincePlanting} day${plant.daysSincePlanting == 1 ? '' : 's'} ago',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              
              // Notes
              if (plant.notes != null && plant.notes!.isNotEmpty) ...[
                SizedBox(height: AppSizes.spacingS),
                Container(
                  padding: EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: Text(
                          plant.notes!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
