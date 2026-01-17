import '../domain/entities/Plant.dart';

/// Data source for plants (mock implementation).
/// In the future, this will be replaced with API calls.
class PlantDataSource {
  final List<Plant> _plants = [];

  /// Initialize with mock data
  PlantDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _plants.addAll([
      Plant(
        id: 1,
        name: 'Basil',
        type: 'Basil',
        description: 'Sweet basil microgreens - perfect for Italian dishes',
        plantingDate: now.subtract(const Duration(days: 5)),
        growthStage: 'Growing',
        healthStatus: 'Healthy',
        notes: 'Growing well, needs daily watering. First harvest in 3 days.',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Plant(
        id: 2,
        name: 'Arugula',
        type: 'Arugula',
        description: 'Spicy arugula microgreens - great for salads',
        plantingDate: now.subtract(const Duration(days: 3)),
        growthStage: 'Seedling',
        healthStatus: 'Healthy',
        notes: 'Just planted, keep soil moist but not waterlogged.',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Plant(
        id: 3,
        name: 'Mint',
        type: 'Mint',
        description: 'Refreshing mint microgreens',
        plantingDate: now.subtract(const Duration(days: 7)),
        growthStage: 'Ready to Harvest',
        healthStatus: 'Healthy',
        notes: 'Ready for harvest! Best time is morning.',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Plant(
        id: 4,
        name: 'Cilantro',
        type: 'Cilantro',
        description: 'Fresh cilantro microgreens',
        plantingDate: now.subtract(const Duration(days: 4)),
        growthStage: 'Growing',
        healthStatus: 'Needs Water',
        notes: 'Soil looks dry, water immediately.',
        createdAt: now.subtract(const Duration(days: 4)),
      ),
    ]);
  }

  /// Get all plants
  Future<List<Plant>> getAllPlants() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return List.from(_plants);
  }

  /// Get plant by ID
  Future<Plant?> getPlantById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _plants.firstWhere((plant) => plant.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new plant
  Future<Plant> addPlant(Plant plant) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newPlant = plant.copyWith(
      id: _plants.isEmpty ? 1 : _plants.map((p) => p.id ?? 0).reduce((a, b) => a > b ? a : b) + 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _plants.add(newPlant);
    return newPlant;
  }

  /// Update an existing plant
  Future<Plant> updatePlant(Plant plant) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _plants.indexWhere((p) => p.id == plant.id);
    if (index == -1) {
      throw Exception('Plant not found');
    }
    final updatedPlant = plant.copyWith(updatedAt: DateTime.now());
    _plants[index] = updatedPlant;
    return updatedPlant;
  }

  /// Delete a plant
  Future<void> deletePlant(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _plants.removeWhere((plant) => plant.id == id);
  }
}

