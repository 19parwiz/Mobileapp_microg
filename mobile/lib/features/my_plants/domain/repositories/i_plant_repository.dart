import '../entities/Plant.dart';

/// Domain abstraction for plant data operations.
///
/// Data layer must implement this and handle API/local storage concerns.
abstract class IPlantRepository {
  /// Get all plants
  Future<List<Plant>> getAllPlants();

  /// Get plant by ID
  Future<Plant?> getPlantById(int id);

  /// Add a new plant
  Future<Plant> addPlant(Plant plant);

  /// Update an existing plant
  Future<Plant> updatePlant(Plant plant);

  /// Delete a plant by ID
  Future<void> deletePlant(int id);
}

