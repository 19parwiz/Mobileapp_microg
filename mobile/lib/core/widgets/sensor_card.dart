import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../features/home/domain/sensor_data.dart';

/// Card widget for displaying sensor readings with title, value, and icon
/// Enhanced with gradients, shadows, plant icons, and animated trend arrows
class SensorCard extends StatefulWidget {
  final String title;
  final String value;
  final String? unit;
  final IconData icon;
  final Color? iconColor;
  final Color? cardColor;
  final VoidCallback? onTap;
  final String? subtitle;
  final Color? valueColor;
  final bool showTrend;
  final TrendDirection? trend;

  const SensorCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.unit,
    this.iconColor,
    this.cardColor,
    this.onTap,
    this.subtitle,
    this.valueColor,
    this.showTrend = false,
    this.trend,
  });

  @override
  State<SensorCard> createState() => _SensorCardState();
}

class _SensorCardState extends State<SensorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _trendAnimationController;
  late Animation<double> _trendScaleAnimation;
  TrendDirection? _previousTrend;

  @override
  void initState() {
    super.initState();
    _trendAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _trendScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(
      CurvedAnimation(
        parent: _trendAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _previousTrend = widget.trend;
  }

  @override
  void didUpdateWidget(SensorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate trend arrow when trend changes
    if (widget.trend != null &&
        widget.trend != _previousTrend &&
        widget.showTrend) {
      _trendAnimationController.forward().then((_) {
        _trendAnimationController.reverse();
      });
      _previousTrend = widget.trend;
    }
  }

  @override
  void dispose() {
    _trendAnimationController.dispose();
    super.dispose();
  }

  IconData _getPlantIcon(String sensorType) {
    switch (sensorType.toLowerCase()) {
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water_drop;
      case 'light':
        return Icons.wb_sunny;
      default:
        return Icons.eco; // Plant icon as default
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardGradient = isDark 
        ? AppColors.cardGradientDark 
        : AppColors.cardGradient;
    
    // Improved contrast colors
    final titleColor = isDark 
        ? AppColors.textOnPrimary 
        : AppColors.textPrimary;
    final subtitleColor = isDark 
        ? AppColors.textOnPrimary.withOpacity(0.8)
        : AppColors.textSecondary;
    final valueTextColor = widget.valueColor ?? titleColor;

    return Card(
      elevation: widget.onTap != null ? 6 : 3,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: widget.cardColor != null ? null : cardGradient,
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and title
                Row(
                  children: [
                    // Icon container with improved contrast
                    Container(
                      padding: const EdgeInsets.all(AppSizes.paddingS),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (widget.iconColor ?? AppColors.primary).withOpacity(0.15),
                            (widget.iconColor ?? AppColors.primary).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: (widget.iconColor ?? AppColors.primary).withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        _getPlantIcon(widget.title),
                        color: widget.iconColor ?? AppColors.primary,
                        size: AppSizes.iconM,
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingM),
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                  letterSpacing: 0.1,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: AppSizes.spacingXS),
                            Text(
                              widget.subtitle!,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: subtitleColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Animated trend indicator
                    if (widget.showTrend && widget.trend != null) ...[
                      ScaleTransition(
                        scale: _trendScaleAnimation,
                        child: widget.trend == TrendDirection.stable
                            ? Icon(
                                Icons.trending_flat,
                                color: subtitleColor,
                                size: AppSizes.iconS,
                              )
                            : Icon(
                                widget.trend == TrendDirection.up
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                color: widget.trend == TrendDirection.up
                                    ? AppColors.success
                                    : AppColors.error,
                                size: AppSizes.iconS,
                              ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSizes.spacingL),
                // Value display with improved contrast
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        widget.value,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: valueTextColor,
                              letterSpacing: -0.5,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.unit != null) ...[
                      const SizedBox(width: AppSizes.spacingXS),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          widget.unit!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: subtitleColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }
}

