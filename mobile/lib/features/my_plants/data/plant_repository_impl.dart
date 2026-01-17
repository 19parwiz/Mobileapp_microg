import '../domain/entities/Plant.dart';
import '../domain/repositories/i_plant_repository.dart';
import 'plant_data_source.dart';

/// Data-layer implementation for plant repository.
/// Uses PlantDataSource (mock) for now. In the future, this will use API calls.
class PlantRepositoryImpl implements IPlantRepository {
  final PlantDataSource _dataSource;

  PlantRepositoryImpl({required PlantDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<Plant>> getAllPlants() async {
    try {
      return await _dataSource.getAllPlants();
    } catch (e) {
      throw Exception('Failed to fetch plants: $e');
    }
  }

  @override
  Future<Plant?> getPlantById(int id) async {
    try {
      return await _dataSource.getPlantById(id);
    } catch (e) {
      throw Exception('Failed to fetch plant: $e');
    }
  }

  @override
  Future<Plant> addPlant(Plant plant) async {
    try {
      return await _dataSource.addPlant(plant);
    } catch (e) {
      throw Exception('Failed to add plant: $e');
    }
  }

  @override
  Future<Plant> updatePlant(Plant plant) async {
    try {
      return await _dataSource.updatePlant(plant);
    } catch (e) {
      throw Exception('Failed to update plant: $e');
    }
  }

  @override
  Future<void> deletePlant(int id) async {
    try {
      await _dataSource.deletePlant(id);
    } catch (e) {
      throw Exception('Failed to delete plant: $e');
    }
  }
}

