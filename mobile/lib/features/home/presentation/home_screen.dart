import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/responsive_constrained.dart';
import './home_provider.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;

  const HomeScreen({super.key, this.showAppBar = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _cameraNames = [
    'Camera 1',
    'Camera 2',
    'Camera 3',
    'Camera 4',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadSensorData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final pageBg = isDark ? const Color(0xFF0F1D14) : const Color(0xFFF2F7EF);

    return Scaffold(
      backgroundColor: pageBg,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Farm Monitor'),
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: AppColors.textPrimary,
              actions: [
                Consumer<HomeProvider>(
                  builder: (context, provider, child) {
                    return IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: provider.isLoading
                          ? null
                          : () => provider.refreshSensorData(),
                    );
                  },
                ),
              ],
            )
          : null,
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          final isInitialLoad =
              provider.isLoading && provider.sensorData.airTemperature == 0;

          if (isInitialLoad) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshSensorData(),
            child: ResponsiveConstrained(
              child: ListView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                children: [
                  _buildHeroCard(theme, provider),
                  const SizedBox(height: AppSizes.spacingL),
                  Text(
                    'Status at a Glance',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingM),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 700 ? 3 : 2;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSizes.spacingM,
                        crossAxisSpacing: AppSizes.spacingM,
                        childAspectRatio: 1.42,
                        children: [
                          _MetricCard(
                            label: 'Temperature',
                            value:
                                '${provider.sensorData.airTemperature.toStringAsFixed(1)} °C',
                            icon: Icons.thermostat_outlined,
                            accent: const Color(0xFF2F8B57),
                            isDark: isDark,
                          ),
                          _MetricCard(
                            label: 'Humidity',
                            value:
                                '${provider.sensorData.airHumidity.toStringAsFixed(1)} %',
                            icon: Icons.water_drop_outlined,
                            accent: const Color(0xFF2F7A47),
                            isDark: isDark,
                          ),
                          _MetricCard(
                            label: 'pH',
                            value: provider.sensorData.phLevel.toStringAsFixed(2),
                            icon: Icons.science_outlined,
                            accent: const Color(0xFF9A8442),
                            isDark: isDark,
                          ),
                          _MetricCard(
                            label: 'EC',
                            value: '${provider.sensorData.ec.toStringAsFixed(3)} mS/cm',
                            icon: Icons.bolt_outlined,
                            accent: const Color(0xFF778B35),
                            isDark: isDark,
                          ),
                          _MetricCard(
                            label: 'CO2',
                            value: '${provider.sensorData.co2.toStringAsFixed(0)} ppm',
                            icon: Icons.co2_outlined,
                            accent: const Color(0xFF7B8D4D),
                            isDark: isDark,
                          ),
                          _MetricCard(
                            label: 'TDS',
                            value: '${provider.sensorData.tds.toStringAsFixed(0)} ppm',
                            icon: Icons.opacity_outlined,
                            accent: const Color(0xFF3C7D5F),
                            isDark: isDark,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Available Device Cameras',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 136,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => _CameraTile(
                        title: _cameraNames[index],
                        isDark: isDark,
                      ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: AppSizes.spacingM),
                      itemCount: _cameraNames.length,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  Wrap(
                    spacing: AppSizes.spacingS,
                    runSpacing: AppSizes.spacingS,
                    children: const [
                      _QuickActionChip(label: 'Quick-chat', icon: Icons.spa),
                      _QuickActionChip(label: 'Elegant suggestion'),
                      _QuickActionChip(label: 'Fast your grow'),
                    ],
                  ),
                  if (provider.hasError)
                    Container(
                      margin: const EdgeInsets.only(top: AppSizes.spacingL),
                      padding: const EdgeInsets.all(AppSizes.paddingM),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.34),
                        ),
                      ),
                      child: Text(
                        'Network issue detected. Displaying latest values.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  const SizedBox(height: AppSizes.spacingXL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroCard(ThemeData theme, HomeProvider provider) {
    final updatedLabel = provider.lastUpdated != null
        ? 'Updated ${_formatTime(provider.lastUpdated!)}'
        : 'Waiting for first update';

    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF97CC9A),
            Color(0xFF5D9162),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.26),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withValues(alpha: 0.24),
            ),
            child: const Icon(
              Icons.hub_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: AppSizes.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Growing Room',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingXS),
                Text(
                  updatedLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            provider.isLoading ? Icons.sync : Icons.sync_rounded,
            color: Colors.white.withValues(alpha: 0.88),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final bool isDark;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isDark
            ? null
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFFFFF), Color(0xFFEAF3E7)],
              ),
        color: isDark ? Theme.of(context).colorScheme.surfaceContainerHigh : null,
        border: Border.all(
          color: isDark
              ? Theme.of(context).colorScheme.outlineVariant
              : const Color(0xFFD7E5D1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Icon(icon, color: accent, size: AppSizes.iconM),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _CameraTile extends StatelessWidget {
  final String title;
  final bool isDark;

  const _CameraTile({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [Color(0xFF3D473C), Color(0xFF1E231D)]
                      : const [Color(0xFFB5A38E), Color(0xFF6D604E)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  margin: const EdgeInsets.all(AppSizes.paddingS),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.paddingS,
                    vertical: AppSizes.paddingXS,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spacingS),
          Center(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final IconData? icon;

  const _QuickActionChip({required this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingS,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A3A2A) : const Color(0xFFEAF4E5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Theme.of(context).colorScheme.outlineVariant
              : const Color(0xFFCBDEC4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppSizes.iconS, color: AppColors.primary),
            const SizedBox(width: AppSizes.spacingS),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
