import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../app/router/app_router.dart';
import 'device_provider.dart';
import '../domain/device.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  @override
  void initState() {
    super.initState();
    // Load devices when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().loadDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgTop = isDark ? const Color(0xFF102116) : const Color(0xFFF6F9F0);
    final bgBottom = isDark ? const Color(0xFF0A180F) : const Color(0xFFDCF0C7);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusM),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primary),
            tooltip: 'Go back',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        title: const Text('My Devices'),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: AppColors.primary),
              tooltip: 'Add device',
              onPressed: () => context.push(AppRouter.addDevice),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: Consumer<DeviceProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.devices.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${provider.errorMessage}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                      ElevatedButton(
                        onPressed: provider.loadDevices,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (provider.devices.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.paddingL),
                    decoration: BoxDecoration(
                      color: isDark
                          ? theme.colorScheme.surfaceContainerHigh
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.devices_outlined,
                          size: 60,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppSizes.spacingM),
                        Text(
                          'No devices found',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingS),
                        Text(
                          'Add your first IoT device to start monitoring.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSizes.spacingL),
                        ElevatedButton.icon(
                          onPressed: () => context.push(AppRouter.addDevice),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Device'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: provider.loadDevices,
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                itemCount: provider.devices.length,
                itemBuilder: (context, index) {
                  final device = provider.devices[index];
                  return _DeviceCard(
                    device: device,
                    onTap: () => context.push('${AppRouter.deviceDetail}/${device.id}'),
                    onEdit: () => context.push('${AppRouter.editDevice}/${device.id}'),
                    onDelete: () => _showDeleteDialog(context, provider, device),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DeviceProvider provider, Device device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text('Are you sure you want to delete "${device.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(this.context);
              Navigator.of(context).pop();
              if (device.id == null) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Unable to delete: invalid device id')),
                );
                return;
              }

              final success = await provider.deleteDevice(device.id!);
              if (success && mounted) {
                messenger.showSnackBar(
                  const SnackBar(content: Text('Device deleted successfully')),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DeviceCard({
    required this.device,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  Color _typeColor(String? deviceType) {
    switch (deviceType?.toLowerCase()) {
      case 'sensor':
        return const Color(0xFF2E7D32);
      case 'controller':
        return const Color(0xFF558B2F);
      case 'camera':
        return const Color(0xFFEF8F00);
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _typeIcon(String? deviceType) {
    switch (deviceType?.toLowerCase()) {
      case 'sensor':
        return Icons.sensors;
      case 'controller':
        return Icons.settings_input_component;
      case 'camera':
        return Icons.camera_alt;
      default:
        return Icons.device_unknown;
    }
  }

  String _typeLabel(String? type) {
    if (type == null || type.trim().isEmpty) {
      return 'Device';
    }
    return '${type[0].toUpperCase()}${type.substring(1).toLowerCase()}';
  }

  String _daysSinceCreated(DateTime? createdAt) {
    if (createdAt == null) {
      return 'Added recently';
    }
    final days = DateTime.now().difference(createdAt).inDays;
    if (days <= 0) {
      return 'Added today';
    }
    return 'Added $days day${days == 1 ? '' : 's'} ago';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? theme.colorScheme.surfaceContainerHigh : Colors.white;
    final outlineColor = isDark ? theme.colorScheme.outlineVariant : const Color(0xFFDCE8D6);
    final accent = _typeColor(device.deviceType);
    final active = device.isActive == true;
    final streamActive = (device.deviceType ?? '').toLowerCase() == 'camera' && active;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingM),
      color: cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: outlineColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
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
                      color: accent,
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: Icon(
                      _typeIcon(device.deviceType),
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
                          device.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          device.description?.isNotEmpty == true
                              ? device.description!
                              : (device.location?.isNotEmpty == true
                                  ? 'This device belongs to ${device.location}'
                                  : 'No description provided'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        onEdit();
                      } else if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: AppSizes.spacingS),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: AppColors.error),
                            SizedBox(width: AppSizes.spacingS),
                            Text('Delete', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingM),
              Wrap(
                spacing: AppSizes.spacingS,
                runSpacing: AppSizes.spacingS,
                children: [
                  _DeviceChip(
                    icon: Icons.devices,
                    label: _typeLabel(device.deviceType),
                    color: accent,
                  ),
                  _DeviceChip(
                    icon: active ? Icons.check_circle : Icons.cancel,
                    label: active ? 'Healthy' : 'Inactive',
                    color: active ? AppColors.success : AppColors.error,
                  ),
                  if (streamActive)
                    const _DeviceChip(
                      icon: Icons.videocam,
                      label: 'Monitor Stream Active',
                      color: Color(0xFF1565C0),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingM),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSizes.spacingXS),
                  Text(
                    _daysSinceCreated(device.createdAt),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingS),
              Text(
                'Status: ${active ? 'Active' : 'Inactive'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: active ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DeviceChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingM,
        vertical: AppSizes.paddingXS,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSizes.spacingXS),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}