import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/responsive_constrained.dart';
import './home_provider.dart';
import 'widgets/sensor_card.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;

  const HomeScreen({super.key, this.showAppBar = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load sensor data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadSensorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('IOT Dashboard'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textPrimary,
              actions: [
                Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    return IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: provider.isLoading
                          ? null
                          : () => provider.refreshSensorData(),
                    );
                  },
                ),
              ],
            )
          : null,
      body: ResponsiveConstrained(
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
          final isInitialLoad = provider.isLoading &&
              provider.sensorData.airTemperature == 0;

          // Loading state
          if (isInitialLoad) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Data loaded
          return RefreshIndicator(
            onRefresh: () => provider.refreshSensorData(),
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              children: [
                // Hero status card
                Container(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.secondaryDark,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.26),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingM),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSizes.radiusL),
                        ),
                        child: const Icon(
                          Icons.hub_rounded,
                          color: Colors.white,
                          size: AppSizes.iconL,
                        ),
                      ),
                      const SizedBox(width: AppSizes.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Growing Room',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSizes.spacingXS),
                            Text(
                              provider.lastUpdated != null
                                  ? 'Updated ${_formatTime(provider.lastUpdated!)}'
                                  : 'Waiting for sensor update',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.spacingL),

                Text(
                  'Environment Metrics',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppSizes.spacingM),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final orientation = MediaQuery.of(context).orientation;
                    final isTablet = constraints.maxWidth >= AppSizes.mobileBreakpoint;
                    final crossAxisCount = isTablet
                        ? (orientation == Orientation.landscape ? 4 : 3)
                        : (orientation == Orientation.landscape ? 3 : 2);
                    final childAspectRatio = orientation == Orientation.landscape
                        ? (isTablet ? 1.35 : 1.15)
                        : (isTablet ? 1.25 : 1.0);

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSizes.spacingM,
                      crossAxisSpacing: AppSizes.spacingM,
                      childAspectRatio: childAspectRatio,
                      children: [
                        SensorCard(
                          label: 'Temperature',
                          value: provider.sensorData.airTemperature,
                          unit: '°C',
                          icon: Icons.thermostat,
                          backgroundColor: const Color(0xFF1F8A70),
                        ),
                        SensorCard(
                          label: 'Humidity',
                          value: provider.sensorData.airHumidity,
                          unit: '%',
                          icon: Icons.water_drop,
                          backgroundColor: const Color(0xFF2979FF),
                        ),
                        SensorCard(
                          label: 'CO2',
                          value: provider.sensorData.co2,
                          unit: 'ppm',
                          icon: Icons.co2,
                          backgroundColor: const Color(0xFFEF6C00),
                          fractionDigits: 0,
                        ),
                        SensorCard(
                          label: 'pH',
                          value: provider.sensorData.phLevel,
                          unit: '',
                          icon: Icons.science_outlined,
                          backgroundColor: const Color(0xFF7B1FA2),
                          fractionDigits: 2,
                        ),
                        SensorCard(
                          label: 'EC',
                          value: provider.sensorData.ec,
                          unit: 'mS/cm',
                          icon: Icons.bolt,
                          backgroundColor: const Color(0xFF1565C0),
                          fractionDigits: 3,
                        ),
                        SensorCard(
                          label: 'TDS',
                          value: provider.sensorData.tds,
                          unit: 'ppm',
                          icon: Icons.opacity,
                          backgroundColor: const Color(0xFF455A64),
                          fractionDigits: 0,
                        ),
                        SensorCard(
                          label: 'Light',
                          value: provider.sensorData.lightLevel,
                          unit: 'lux',
                          icon: Icons.wb_sunny,
                          backgroundColor: const Color(0xFFF9A825),
                          textColor: Colors.black87,
                          iconColor: Colors.black87,
                          fractionDigits: 0,
                        ),
                        SensorCard(
                          label: 'Turbidity',
                          value: provider.sensorData.turbidity,
                          unit: 'NTU',
                          icon: Icons.grain,
                          backgroundColor: const Color(0xFF6D4C41),
                          fractionDigits: 0,
                        ),
                      ],
                    );
                  },
                ),

                // Soil Moisture Section
                Container(
                  margin: const EdgeInsets.only(top: AppSizes.spacingL),
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                    border: Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Substrate Moisture',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                      Wrap(
                        spacing: AppSizes.spacingS,
                        runSpacing: AppSizes.spacingS,
                        children: [
                          _buildSoilChip(context, 'Shelf 1', provider.sensorData.soil1),
                          _buildSoilChip(context, 'Shelf 2', provider.sensorData.soil2),
                          _buildSoilChip(context, 'Shelf 3', provider.sensorData.soil3),
                          _buildSoilChip(context, 'Shelf 4', provider.sensorData.soil4),
                          _buildSoilChip(context, 'Shelf 5', provider.sensorData.soil5),
                        ],
                      ),
                    ],
                  ),
                ),

                if (provider.hasError)
                  Container(
                    margin: const EdgeInsets.only(top: AppSizes.spacingM),
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.textPrimary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: AppSizes.spacingS),
                        Expanded(
                          child: Text(
                            'Temporary network issue. Showing latest available values.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSizes.spacingXL),
              ],
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildSoilChip(BuildContext context, String label, double value) {
    final active = value > 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: active
            ? AppColors.soilColor.withValues(alpha: 0.14)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXL),
        border: Border.all(
          color: active
              ? AppColors.soilColor.withValues(alpha: 0.45)
              : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: AppSizes.spacingS),
          Text(
            value.toStringAsFixed(1),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  /// Format timestamp for display
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}
