import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../domain/entities/Plant.dart';

/// Dialog for adding or editing a plant
class AddPlantDialog extends StatefulWidget {
  final Plant? plant; // If provided, we're editing; otherwise, adding

  const AddPlantDialog({super.key, this.plant});

  @override
  State<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<AddPlantDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  
  String _selectedGrowthStage = 'Seedling';
  String? _selectedHealthStatus;
  DateTime? _selectedPlantingDate;

  final List<String> _growthStages = [
    'Seedling',
    'Growing',
    'Ready to Harvest',
    'Harvested',
  ];

  final List<String> _healthStatuses = [
    'Healthy',
    'Needs Water',
    'Warning',
  ];

  final List<String> _plantTypes = [
    'Basil',
    'Arugula',
    'Mint',
    'Cilantro',
    'Lettuce',
    'Spinach',
    'Radish',
    'Pea Shoots',
    'Sunflower',
    'Broccoli',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant?.name ?? '');
    _typeController = TextEditingController(text: widget.plant?.type ?? '');
    _descriptionController = TextEditingController(text: widget.plant?.description ?? '');
    _notesController = TextEditingController(text: widget.plant?.notes ?? '');
    _selectedGrowthStage = widget.plant?.growthStage ?? 'Seedling';
    _selectedHealthStatus = widget.plant?.healthStatus;
    _selectedPlantingDate = widget.plant?.plantingDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectPlantingDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedPlantingDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedPlantingDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.plant == null ? 'Add New Plant' : 'Edit Plant',
        style: TextStyle(color: AppColors.primary),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plant name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Plant Name *',
                  prefixIcon: Icon(Icons.local_florist),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter plant name' : null,
              ),
              SizedBox(height: AppSizes.spacingM),
              
              // Plant type dropdown
              DropdownButtonFormField<String>(
                value: _typeController.text.isEmpty ? null : _typeController.text,
                decoration: const InputDecoration(
                  labelText: 'Plant Type *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _plantTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    _typeController.text = value;
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select plant type'
                    : null,
              ),
              const SizedBox(height: AppSizes.spacingM),
              
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.spacingM),
              
              // Planting date
              InkWell(
                onTap: _selectPlantingDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Planting Date *',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedPlantingDate != null
                        ? '${_selectedPlantingDate!.day}/${_selectedPlantingDate!.month}/${_selectedPlantingDate!.year}'
                        : 'Select date',
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingM),
              
              // Growth stage
              DropdownButtonFormField<String>(
                value: _selectedGrowthStage,
                decoration: const InputDecoration(
                  labelText: 'Growth Stage *',
                  prefixIcon: Icon(Icons.trending_up),
                ),
                items: _growthStages.map((stage) {
                  return DropdownMenuItem(
                    value: stage,
                    child: Text(stage),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGrowthStage = value;
                    });
                  }
                },
              ),
              const SizedBox(height: AppSizes.spacingM),
              
              // Health status
              DropdownButtonFormField<String>(
                value: _selectedHealthStatus,
                decoration: const InputDecoration(
                  labelText: 'Health Status',
                  prefixIcon: Icon(Icons.favorite),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('None'),
                  ),
                  ..._healthStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedHealthStatus = value;
                  });
                },
              ),
              const SizedBox(height: AppSizes.spacingM),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _selectedPlantingDate != null) {
              final plant = Plant(
                id: widget.plant?.id,
                name: _nameController.text.trim(),
                type: _typeController.text.trim(),
                description: _descriptionController.text.trim().isEmpty
                    ? null
                    : _descriptionController.text.trim(),
                plantingDate: _selectedPlantingDate,
                growthStage: _selectedGrowthStage,
                healthStatus: _selectedHealthStatus,
                notes: _notesController.text.trim().isEmpty
                    ? null
                    : _notesController.text.trim(),
                createdAt: widget.plant?.createdAt ?? DateTime.now(),
                updatedAt: DateTime.now(),
              );
              Navigator.of(context).pop(plant);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
          ),
          child: Text(widget.plant == null ? 'Add Plant' : 'Save Changes'),
        ),
      ],
    );
  }
}
