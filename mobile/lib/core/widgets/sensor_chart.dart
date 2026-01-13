import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../features/home/domain/sensor_data.dart';

/// Dynamic chart widget for displaying sensor data over time
class SensorChart extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<SensorData> data;
  final VoidCallback? onTap;

  const SensorChart({
    super.key,
    required this.title,
    this.subtitle,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Group data by sensor type
    final temperatureData =
        data.where((d) => d.sensorType == 'temperature').toList();
    final humidityData = data.where((d) => d.sensorType == 'humidity').toList();
    final lightData = data.where((d) => d.sensorType == 'light').toList();

    // Prepare data for fl_chart
    final List<FlSpot> temperatureSpots = [];
    final List<FlSpot> humiditySpots = [];
    final List<FlSpot> lightSpots = [];

    // Convert to FlSpot format (x = index, y = value)
    for (int i = 0; i < temperatureData.length; i++) {
      temperatureSpots.add(FlSpot(i.toDouble(), temperatureData[i].value));
    }
    for (int i = 0; i < humidityData.length; i++) {
      humiditySpots.add(FlSpot(i.toDouble(), humidityData[i].value));
    }
    for (int i = 0; i < lightData.length; i++) {
      lightSpots.add(FlSpot(i.toDouble(), lightData[i].value));
    }

    final hasData = temperatureSpots.isNotEmpty ||
        humiditySpots.isNotEmpty ||
        lightSpots.isNotEmpty;

    // Calculate maxY value
    double maxYValue = 100.0;
    if (hasData) {
      double maxValue = 0;
      if (temperatureSpots.isNotEmpty) {
        final tempMax =
            temperatureSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        if (tempMax > maxValue) maxValue = tempMax;
      }
      if (humiditySpots.isNotEmpty) {
        final humMax =
            humiditySpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        if (humMax > maxValue) maxValue = humMax;
      }
      if (lightSpots.isNotEmpty) {
        final lightMax =
            lightSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
        if (lightMax > maxValue) maxValue = lightMax;
      }
      maxYValue = maxValue > 0 ? maxValue * 1.2 : 100.0;
    }

    return Card(
      elevation: onTap != null ? 6 : 3,
      shadowColor: AppColors.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient:
              isDark ? AppColors.cardGradientDark : AppColors.cardGradient,
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
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
            splashColor: AppColors.primary.withOpacity(0.1),
            highlightColor: AppColors.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with improved contrast
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: isDark
                                      ? AppColors.textOnPrimary
                                      : AppColors.textPrimary,
                                  letterSpacing: 0.2,
                                ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AppSizes.spacingXS),
                            Text(
                              subtitle!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isDark
                                        ? AppColors.textOnPrimary
                                            .withOpacity(0.8)
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      Icons.show_chart,
                      color: AppColors.primary,
                      size: AppSizes.iconL,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingL),
                // Chart
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
                  child: !hasData
                      ? Center(
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
                                'No data available',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textHint,
                                      fontStyle: FontStyle.italic,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingS),
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: AppColors.border,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${value.toInt()}',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.textOnPrimary
                                              : AppColors.textPrimary,
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.textOnPrimary
                                              : AppColors.textPrimary,
                                          fontSize: 10,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                              minX: 0,
                              maxX: hasData
                                  ? (temperatureSpots.isNotEmpty
                                      ? temperatureSpots.length.toDouble()
                                      : humiditySpots.isNotEmpty
                                          ? humiditySpots.length.toDouble()
                                          : lightSpots.length.toDouble())
                                  : 10,
                              minY: 0,
                              maxY: maxYValue,
                              lineBarsData: [
                                if (temperatureSpots.isNotEmpty)
                                  LineChartBarData(
                                    spots: temperatureSpots,
                                    isCurved: true,
                                    color: AppColors.warning,
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                if (humiditySpots.isNotEmpty)
                                  LineChartBarData(
                                    spots: humiditySpots,
                                    isCurved: true,
                                    color: AppColors.primary,
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                if (lightSpots.isNotEmpty)
                                  LineChartBarData(
                                    spots: lightSpots,
                                    isCurved: true,
                                    color: AppColors.accent,
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    dotData: const FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                              ],
                            ),
                          ),
                        ),
                ),
                // Legend
                if (hasData) ...[
                  const SizedBox(height: AppSizes.spacingM),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (temperatureSpots.isNotEmpty) ...[
                        _buildLegendItem(
                            context, 'Temperature', AppColors.warning),
                        const SizedBox(width: AppSizes.spacingM),
                      ],
                      if (humiditySpots.isNotEmpty) ...[
                        _buildLegendItem(
                            context, 'Humidity', AppColors.primary),
                        const SizedBox(width: AppSizes.spacingM),
                      ],
                      if (lightSpots.isNotEmpty)
                        _buildLegendItem(context, 'Light', AppColors.accent),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? AppColors.textOnPrimary.withOpacity(0.3)
                  : AppColors.border,
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.spacingXS),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textOnPrimary.withOpacity(0.9)
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
