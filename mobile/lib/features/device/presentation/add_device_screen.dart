import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input.dart';
import '../domain/device.dart';
import 'device_provider.dart';

class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _deviceTypeController = TextEditingController();
  final _locationController = TextEditingController();

  String? _selectedDeviceType;
  bool _isActive = true;

  final List<String> _deviceTypes = ['Sensor', 'Controller', 'Camera', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _deviceIdController.dispose();
    _descriptionController.dispose();
    _deviceTypeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Add Device'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSizes.spacingL),
                AppInput(
                  label: 'Device Name *',
                  hint: 'Enter device name',
                  controller: _nameController,
                  prefixIcon: Icons.devices,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Device name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.spacingL),
                AppInput(
                  label: 'Device ID',
                  hint: 'Enter unique device identifier',
                  controller: _deviceIdController,
                  prefixIcon: Icons.tag,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingL),
                DropdownButtonFormField<String>(
                  value: _selectedDeviceType,
                  decoration: InputDecoration(
                    labelText: 'Device Type',
                    hintText: 'Select device type',
                    prefixIcon: const Icon(Icons.category),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      borderSide: const BorderSide(
                        color: AppColors.borderFocus,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingM,
                      vertical: AppSizes.paddingM,
                    ),
                  ),
                  items: _deviceTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDeviceType = value;
                    });
                  },
                ),
                const SizedBox(height: AppSizes.spacingL),
                AppInput(
                  label: 'Location',
                  hint: 'Enter device location',
                  controller: _locationController,
                  prefixIcon: Icons.location_on,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSizes.spacingL),
                AppInput(
                  label: 'Description',
                  hint: 'Enter device description',
                  controller: _descriptionController,
                  prefixIcon: Icons.description,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: AppSizes.spacingL),
                SwitchListTile(
                  title: const Text('Active'),
                  subtitle: const Text('Is this device currently active?'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  activeColor: AppColors.primary,
                ),
                const SizedBox(height: AppSizes.spacingXL),
                Consumer<DeviceProvider>(
                  builder: (context, provider, child) {
                    return AppButton(
                      text: 'Add Device',
                      onPressed: provider.isLoading ? null : _handleAddDevice,
                      isLoading: provider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAddDevice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final device = Device(
      name: _nameController.text.trim(),
      deviceId: _deviceIdController.text.trim().isEmpty
          ? null
          : _deviceIdController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      deviceType: _selectedDeviceType,
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      isActive: _isActive,
    );

    final provider = context.read<DeviceProvider>();
    final success = await provider.createDevice(device);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device added successfully')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add device: ${provider.errorMessage}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}