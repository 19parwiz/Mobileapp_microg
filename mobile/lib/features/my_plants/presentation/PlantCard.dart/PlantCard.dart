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

  bool _isStreamActive(Plant plant) {
    final source = '${plant.name} ${plant.type} ${plant.description ?? ''}'.toLowerCase();
    return source.contains('hls') || source.contains('stream');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white;
    final outlineColor = isDark ? theme.colorScheme.outlineVariant : const Color(0xFFDCE8D6);

    final stageColor = _getGrowthStageColor(plant.growthStage);
    final healthColor = _getHealthColor(plant.healthStatus);
    final streamActive = _isStreamActive(plant);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: outlineColor),
      ),
      color: cardColor,
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Center(
                      child: Text(
                        plant.iconEmoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plant.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ),
                        ),
                        const SizedBox(height: AppSizes.spacingXS),
                        Text(
                          plant.type,
                          style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (onEdit != null)
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
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

              const SizedBox(height: AppSizes.spacingM),

              if (plant.description != null && plant.description!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSizes.spacingS),
                  child: Text(
                    plant.description!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              Wrap(
                spacing: AppSizes.spacingS,
                runSpacing: AppSizes.spacingS,
                children: [
                  _StatusChip(
                    icon: Icons.spa,
                    label: plant.growthStage,
                    foreground: stageColor,
                  ),
                  if (plant.healthStatus != null)
                    _StatusChip(
                      icon: plant.healthStatus?.toLowerCase() == 'healthy'
                          ? Icons.check_circle
                          : Icons.warning,
                      label: plant.healthStatus!,
                      foreground: healthColor,
                    ),
                  if (streamActive)
                    const _StatusChip(
                      icon: Icons.videocam,
                      label: 'Monitor Stream Active',
                      foreground: Color(0xFF1565C0),
                    ),
                ],
              ),

              const SizedBox(height: AppSizes.spacingM),

              if (plant.daysSincePlanting != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSizes.spacingXS),
                    Text(
                      'Planted ${plant.daysSincePlanting} day${plant.daysSincePlanting == 1 ? '' : 's'} ago',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),

              if (plant.notes != null && plant.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSizes.spacingM),
                Text(
                  'NOTES',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingS),
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingM),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(color: outlineColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.spacingS),
                      Expanded(
                        child: Text(
                          plant.notes!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface,
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

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color foreground;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: foreground.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: AppSizes.spacingXS),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
