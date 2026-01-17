import '../entities/Plant.dart';
import '../repositories/i_plant_repository.dart';

/// Use case: Update an existing plant
class UpdatePlantUseCase {
  final IPlantRepository _repository;

  UpdatePlantUseCase({required IPlantRepository repository})
      : _repository = repository;

  Future<Plant> call(Plant plant) {
    return _repository.updatePlant(plant);
  }
}

