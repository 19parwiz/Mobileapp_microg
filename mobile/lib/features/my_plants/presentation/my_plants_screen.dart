import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/responsive_constrained.dart';
import 'providers/PlantProvider.dart';
import 'PlantCard.dart/PlantCard.dart';
import 'PlantCard.dart/add_plant_dialog.dart';
import '../../../features/my_plants/domain/entities/Plant.dart';

/// My Plants screen for managing microgreen plants
class MyPlantsScreen extends StatefulWidget {
  /// Whether to show AppBar (for standalone routes) or not (for MainScaffold tabs)
  final bool showAppBar;
  
  const MyPlantsScreen({super.key, this.showAppBar = false});

  @override
  State<MyPlantsScreen> createState() => _MyPlantsScreenState();
}

class _MyPlantsScreenState extends State<MyPlantsScreen> {
  bool _hasInitialized = false;

  Future<void> _showAddPlantDialog(BuildContext context, PlantProvider provider) async {
    final result = await showDialog<Plant>(
      context: context,
      builder: (context) => const AddPlantDialog(),
    );
    
    if (result != null) {
      await provider.addPlant(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} added successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showEditPlantDialog(BuildContext context, PlantProvider provider, Plant plant) async {
    final result = await showDialog<Plant>(
      context: context,
      builder: (context) => AddPlantDialog(plant: plant),
    );
    
    if (result != null) {
      await provider.updatePlant(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} updated successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, PlantProvider provider, Plant plant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plant'),
        content: Text('Are you sure you want to delete "${plant.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await provider.deletePlant(plant.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plant.name} deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context, PlantProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingXL),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_florist,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingL),
            Text(
              'No Plants Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: AppSizes.spacingM),
            Text(
              'Start growing your microgreens! Add your first plant to track its growth and health.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSizes.spacingXL),
            ElevatedButton.icon(
              onPressed: () => _showAddPlantDialog(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Plant'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingL,
                  vertical: AppSizes.paddingM,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PlantProvider provider) {
    if (provider.isLoading) {
      return const Center(child: AppLoading());
    }

    if (provider.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: AppSizes.spacingM),
              Text(
                'Error Loading Plants',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                provider.errorMessage ?? 'Unknown error',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSizes.spacingL),
              ElevatedButton(
                onPressed: () => provider.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.plants.isEmpty) {
      return _buildEmptyState(context, provider);
    }

    return RefreshIndicator(
      onRefresh: () => provider.refresh(),
      child: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        children: [
          // Header with plant count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Garden',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingM,
                  vertical: AppSizes.paddingXS,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusM),
                ),
                child: Text(
                  '${provider.plantCount} plant${provider.plantCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingL),
          
          // Plant cards
          ...provider.plants.map((plant) => PlantCard(
                plant: plant,
                onEdit: () => _showEditPlantDialog(context, provider, plant),
                onDelete: () => _showDeleteConfirmation(context, provider, plant),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the DI-registered PlantProvider (do NOT recreate or dispose it here)
    final provider = context.watch<PlantProvider>();

    // Trigger initial fetch ONLY ONCE on first build
    if (!_hasInitialized) {
      _hasInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.fetchPlants();
      });
    }

    Widget content = SafeArea(
      child: ResponsiveConstrained(
        child: Column(
        children: [
          // Search bar (optional - can be added later)
          // For now, just show the content
          Expanded(
            child: _buildContent(context, provider),
          ),
        ],
        ),
      ),
    );

    // Floating action button for adding plants
    if (!provider.isLoading && !provider.hasError) {
      content = Stack(
        children: [
          content,
          Positioned(
            bottom: AppSizes.spacingL,
            right: AppSizes.spacingL,
            child: FloatingActionButton.extended(
              onPressed: () => _showAddPlantDialog(context, provider),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Add Plant'),
            ),
          ),
        ],
      );
    }

    // If showAppBar is true (standalone route), wrap in Scaffold with AppBar
    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Plants'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => provider.refresh(),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: content,
      );
    }

    // If embedded in MainScaffold (showAppBar = false), return just the content (no Scaffold)
    return content;
  }
}
