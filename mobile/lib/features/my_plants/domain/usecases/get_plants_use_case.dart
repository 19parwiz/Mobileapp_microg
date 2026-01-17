import '../entities/Plant.dart';
import '../repositories/i_plant_repository.dart';

/// Use case: Get all plants
class GetPlantsUseCase {
  final IPlantRepository _repository;

  GetPlantsUseCase({required IPlantRepository repository})
      : _repository = repository;

  Future<List<Plant>> call() {
    return _repository.getAllPlants();
  }
}

