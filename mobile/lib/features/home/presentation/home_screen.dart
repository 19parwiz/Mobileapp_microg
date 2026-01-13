import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/sensor_card.dart';
import '../../../core/widgets/sensor_card_skeleton.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/sensor_chart.dart';
import '../../../app/router/app_router.dart';
import 'home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _updateAnimationController;
  late Animation<double> _chartScaleAnimation;
  late Animation<double> _chartFadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _updateAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Chart animations - Scale + Fade
    _chartScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
    
    _chartFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    ));
    
    // Initialize provider if not already initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<HomeProvider>().isLoading) {
        context.read<HomeProvider>().updateSensorData();
      }
      // Start animations after data is loaded
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _updateAnimationController.dispose();
    super.dispose();
  }

  /// Handle back button press with confirmation dialog
  Future<void> _handleBackButton() async {
    debugPrint('Back button pressed on HomeDashboard');
    if (!mounted) return;
    
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit HomeDashboard?'),
        content: const Text('Do you want to exit the HomeDashboard?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('User chose to stay on HomeDashboard');
              Navigator.of(context).pop(false);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint('User chose to exit HomeDashboard');
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      // Exit the app
      Navigator.of(context).pop();
    }
  }

  void _handleCameraPress(BuildContext context) {
    debugPrint('Camera button pressed - navigating to camera screen');
    context.push(AppRouter.camera).then((_) {
      debugPrint('Returned from camera screen');
    });
  }

  void _handleAIPress(BuildContext context) {
    debugPrint('AI button pressed - navigating to AI screen');
    context.push(AppRouter.ai).then((_) {
      debugPrint('Returned from AI screen');
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _handleBackButton();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.eco,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSizes.spacingS),
              const Text(AppStrings.home),
            ],
          ),
        ),
        body: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            // Loading state with skeletons
            if (provider.isLoading) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome skeleton
                      Card(
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppColors.cardGradient,
                            borderRadius: BorderRadius.circular(AppSizes.radiusL),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingL),
                      Text(
                        'Sensor Readings',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                      // Sensor card skeletons
                      const SensorCardSkeleton(),
                      const SizedBox(height: AppSizes.spacingM),
                      const SensorCardSkeleton(),
                      const SizedBox(height: AppSizes.spacingM),
                      const SensorCardSkeleton(),
                    ],
                  ),
                ),
              );
            }

            // Error state
            if (provider.hasError) {
              return SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                        Text(
                          'Error Loading Data',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                        ),
                        const SizedBox(height: AppSizes.spacingS),
                        Text(
                          provider.errorMessage ?? 'An unknown error occurred',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.updateSensorData();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Retry',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: AppColors.textOnPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingL,
                                vertical: AppSizes.paddingL,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                              ),
                              minimumSize: const Size(0, AppSizes.buttonHeightL),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Empty state
            if (provider.sensorData.isEmpty) {
              return SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.paddingXL),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sensors_off,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                        Text(
                          'No Sensor Data',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                        ),
                        const SizedBox(height: AppSizes.spacingS),
                        Text(
                          'Sensor data will appear here when available',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.updateSensorData();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text(
                              'Refresh',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: AppColors.textOnPrimary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSizes.paddingL,
                                vertical: AppSizes.paddingL,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                              ),
                              minimumSize: const Size(0, AppSizes.buttonHeightL),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Animate on data updates
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateAnimationController.forward(from: 0).then((_) {
                _updateAnimationController.reverse();
              });
            });

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Welcome header with plant icon and gradient - with fade-in animation
                    FadeTransition(
                      opacity: _chartFadeAnimation,
                      child: ScaleTransition(
                        scale: _chartScaleAnimation,
                        child: Card(
                          elevation: 4,
                          shadowColor: AppColors.primary.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.cardGradient,
                              borderRadius: BorderRadius.circular(AppSizes.radiusXL),
                            ),
                            child: Padding(
                          padding: const EdgeInsets.all(AppSizes.paddingL),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSizes.paddingM),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary.withOpacity(0.2),
                                      AppColors.primary.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.eco,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: AppSizes.spacingM),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      AppStrings.welcome,
                                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                            color: AppColors.textPrimary,
                                            letterSpacing: 0.2,
                                          ),
                                    ),
                                    const SizedBox(height: AppSizes.spacingS),
                                    Text(
                                      'Microgreens Management Dashboard',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                        ),
                      ),
                    const SizedBox(height: AppSizes.spacingXL),
                    
                    // Sensor Cards Section - Using ListView for dynamic cards
                    Text(
                      'Sensor Readings',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    
                    // Dynamic Sensor Cards List with staggered animations
                    SizedBox(
                      height: provider.sensorData.length * 100.0, // Approximate height
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.sensorData.length,
                        itemBuilder: (context, index) {
                          final sensor = provider.sensorData[index];
                          debugPrint('Building sensor card: ${sensor.sensorType} = ${sensor.value}');
                          
                          // Determine icon and color based on sensor type
                          IconData icon;
                          Color iconColor;
                          String subtitle;
                          
                          switch (sensor.sensorType) {
                            case 'temperature':
                              icon = Icons.thermostat;
                              iconColor = AppColors.warning;
                              subtitle = 'Optimal range: 20-25°C';
                              break;
                            case 'humidity':
                              icon = Icons.water_drop;
                              iconColor = AppColors.primary;
                              subtitle = 'Optimal range: 60-70%';
                              break;
                            case 'light':
                              icon = Icons.wb_sunny;
                              iconColor = AppColors.accent;
                              subtitle = 'Optimal range: 500-1000 lux';
                              break;
                            default:
                              icon = Icons.sensors;
                              iconColor = AppColors.primary;
                              subtitle = 'Sensor reading';
                          }
                          
                          // Staggered animation: each card starts 0.1s after the previous
                          final delay = index * 0.1;
                          final animation = Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                delay.clamp(0.0, 0.4),
                                (delay + 0.4).clamp(0.0, 1.0),
                                curve: Curves.easeOut,
                              ),
                            ),
                          );
                          
                          return _AnimatedSensorCard(
                            animation: animation,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: index < provider.sensorData.length - 1 
                                    ? AppSizes.spacingM 
                                    : 0,
                              ),
                              child: SensorCard(
                                title: sensor.sensorType[0].toUpperCase() + 
                                       sensor.sensorType.substring(1),
                                value: sensor.sensorType == 'light' 
                                    ? sensor.value.toStringAsFixed(0)
                                    : sensor.value.toStringAsFixed(1),
                                unit: sensor.unit,
                                icon: icon,
                                iconColor: iconColor,
                                subtitle: subtitle,
                                showTrend: true,
                                trend: sensor.trend,
                                onTap: () {
                                  debugPrint('${sensor.sensorType} card tapped: ${sensor.value} ${sensor.unit}');
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXL),
                    
                    // Chart Section - Dynamic
                    Text(
                      'Sensor Data Chart',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    // Animated Chart with Scale + Fade + Update animation
                    AnimatedBuilder(
                      animation: _updateAnimationController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: 1.0 - (_updateAnimationController.value * 0.3),
                          child: Transform.scale(
                            scale: 1.0 - (_updateAnimationController.value * 0.05),
                            child: child,
                          ),
                        );
                      },
                      child: ScaleTransition(
                        scale: _chartScaleAnimation,
                        child: FadeTransition(
                          opacity: _chartFadeAnimation,
                          child: provider.chartData.isEmpty
                              ? Card(
                                  child: Container(
                                    height: 200,
                                    padding: const EdgeInsets.all(AppSizes.paddingL),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.show_chart,
                                            size: 48,
                                            color: AppColors.textSecondary.withOpacity(0.5),
                                          ),
                                          const SizedBox(height: AppSizes.spacingM),
                                          Text(
                                            'No chart data available',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : SensorChart(
                                  title: 'Sensor Readings Over Time',
                                  subtitle: 'Last 24 hours',
                                  data: provider.chartData,
                                  onTap: () {
                                    debugPrint(
                                        'Chart tapped - ${provider.chartData.length} data points');
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.spacingXL),
                    
                    // Action Buttons Section
                    Text(
                      'Quick Actions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            letterSpacing: 0.2,
                          ),
                    ),
                    const SizedBox(height: AppSizes.spacingL),
                    
                    // Camera Button - Dynamic with navigation with gradient
                    CustomButton(
                      text: 'Open Camera',
                      style: CustomButtonStyle.primary,
                      icon: Icons.camera_alt,
                      onPressed: () => _handleCameraPress(context),
                    ),
                    const SizedBox(height: AppSizes.spacingM),
                    
                    // AI Button - Dynamic with navigation
                    CustomButton(
                      text: 'AI Predictions',
                      style: CustomButtonStyle.secondary,
                      icon: Icons.eco,
                      onPressed: () => _handleAIPress(context),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Animated sensor card wrapper with Fade + Slide animation
class _AnimatedSensorCard extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _AnimatedSensorCard({
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Fade animation
        final fadeValue = animation.value;
        
        // Slide animation (from bottom)
        final slideOffset = Tween<double>(
          begin: 30.0,
          end: 0.0,
        ).evaluate(CurvedAnimation(
          parent: AlwaysStoppedAnimation(animation.value),
          curve: Curves.easeOut,
        ));
        
        return Opacity(
          opacity: fadeValue,
          child: Transform.translate(
            offset: Offset(0, slideOffset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
