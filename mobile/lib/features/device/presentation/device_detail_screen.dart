import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../app/router/app_router.dart';
import '../domain/device.dart';
import 'device_provider.dart';

class DeviceDetailScreen extends StatefulWidget {
  final int deviceId;

  const DeviceDetailScreen({super.key, required this.deviceId});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load device details when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDevice();
    });
  }

  Future<void> _loadDevice() async {
    final provider = context.read<DeviceProvider>();
    await provider.getDeviceById(widget.deviceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
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
        title: const Text('Device Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('${AppRouter.editDevice}/${widget.deviceId}'),
          ),
        ],
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, provider, child) {
          // Find the device in the list
          final device = provider.devices.where((d) => d.id == widget.deviceId).firstOrNull;

          // If device not found in list, show error
          if (device == null && provider.devices.isEmpty && !provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.device_unknown,
                    size: 80,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSizes.spacingL),
                  Text(
                    'Device not found',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: AppSizes.spacingXL),
                  CustomButton(
                    text: 'Go Back',
                    onPressed: () => context.go(AppRouter.devices),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: device != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Device Header Card
                      Card(
                        elevation: 2,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSizes.paddingL),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _getDeviceTypeColor(device.deviceType),
                                      borderRadius: BorderRadius.circular(AppSizes.radiusL),
                                    ),
                                    child: Icon(
                                      _getDeviceTypeIcon(device.deviceType),
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.spacingL),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          device.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: AppSizes.spacingXS),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSizes.paddingS,
                                            vertical: AppSizes.paddingXS,
                                          ),
                                          decoration: BoxDecoration(
                                            color: device.isActive == true
                                                ? AppColors.success.withOpacity(0.2)
                                                : AppColors.error.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(AppSizes.radiusS),
                                          ),
                                          child: Text(
                                            device.isActive == true
                                                ? 'Active'
                                                : 'Inactive',
                                            style: TextStyle(
                                              color: device.isActive == true
                                                  ? AppColors.success
                                                  : AppColors.error,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.spacingL),
                      // Device Information
                      _buildSection(
                        title: 'Device Information',
                        children: [
                          _buildInfoRow('Device Type', device.deviceType ?? 'N/A'),
                          if (device.deviceId != null)
                            _buildInfoRow('Device ID', device.deviceId!),
                          if (device.location != null)
                            _buildInfoRow('Location', device.location!),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingL),
                      // Description
                      if (device.description != null && device.description!.isNotEmpty)
                        _buildSection(
                          title: 'Description',
                          children: [
                            Text(
                              device.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      if (device.description != null && device.description!.isNotEmpty)
                        const SizedBox(height: AppSizes.spacingL),
                      // Timestamps
                      _buildSection(
                        title: 'Timestamps',
                        children: [
                          if (device.createdAt != null)
                            _buildInfoRow(
                              'Created',
                              _formatDateTime(device.createdAt!),
                            ),
                          if (device.lastSeen != null)
                            _buildInfoRow(
                              'Last Seen',
                              _formatDateTime(device.lastSeen!),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.spacingXL),
                      // Action Buttons
                      CustomButton(
                        text: 'Edit Device',
                        onPressed: () =>
                            context.push('${AppRouter.editDevice}/${device.id}'),
                      ),
                      const SizedBox(height: AppSizes.spacingM),
                      CustomButton(
                        text: 'Delete Device',
                        backgroundColor: AppColors.error,
                        onPressed: () => _showDeleteDialog(context),
                      ),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSizes.spacingM),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  IconData _getDeviceTypeIcon(String? deviceType) {
    switch (deviceType?.toLowerCase()) {
      case 'sensor':
        return Icons.sensors;
      case 'controller':
        return Icons.settings_remote;
      case 'camera':
        return Icons.camera_alt;
      default:
        return Icons.device_unknown;
    }
  }

  Color _getDeviceTypeColor(String? deviceType) {
    switch (deviceType?.toLowerCase()) {
      case 'sensor':
        return AppColors.primary;
      case 'controller':
        return AppColors.secondary;
      case 'camera':
        return Colors.orange;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    Device? device;
    try {
      device = context.read<DeviceProvider>().devices.firstWhere((d) => d.id == widget.deviceId);
    } catch (e) {
      device = null;
    }

    if (device == null) return;

    final deviceToDelete = device;
    if (deviceToDelete.id == null) return; // ensure id exists before actions

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device'),
        content: Text(
            'Are you sure you want to delete "${deviceToDelete.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final provider = context.read<DeviceProvider>();
              final success = await provider.deleteDevice(deviceToDelete.id!);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device deleted successfully')),
                );
                context.go(AppRouter.devices);
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(provider.errorMessage ?? 'Failed to delete device'),
                    backgroundColor: AppColors.error,
                  ),
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
