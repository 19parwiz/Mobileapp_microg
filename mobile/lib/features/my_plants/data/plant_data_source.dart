import '../domain/entities/Plant.dart';
import 'plant_api.dart';

/// Data source for plants - now connected to backend API
class PlantDataSource {
  final PlantApi _plantApi;

  PlantDataSource({required PlantApi plantApi}) : _plantApi = plantApi;

  /// Get all plants from backend API
  Future<List<Plant>> getAllPlants() async {
    return await _plantApi.getAllPlants();
  }

  /// Get plant by ID from backend API
  Future<Plant?> getPlantById(int id) async {
    try {
      return await _plantApi.getPlantById(id);
    } catch (e) {
      return null;
    }
  }

  /// Add a new plant via backend API
  Future<Plant> addPlant(Plant plant) async {
    return await _plantApi.createPlant(plant);
  }

  /// Update an existing plant via backend API
  Future<Plant> updatePlant(Plant plant) async {
    if (plant.id == null) {
      throw Exception('Plant ID is required for update');
    }
    return await _plantApi.updatePlant(plant.id!, plant);
  }

  /// Delete a plant via backend API
  Future<void> deletePlant(int id) async {
    await _plantApi.deletePlant(id);
  }
}

