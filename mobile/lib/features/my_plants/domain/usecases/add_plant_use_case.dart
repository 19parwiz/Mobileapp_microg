import '../entities/Plant.dart';
import '../repositories/i_plant_repository.dart';

/// Use case: Add a new plant
class AddPlantUseCase {
  final IPlantRepository _repository;

  AddPlantUseCase({required IPlantRepository repository})
      : _repository = repository;

  Future<Plant> call(Plant plant) {
    return _repository.addPlant(plant);
  }
}

