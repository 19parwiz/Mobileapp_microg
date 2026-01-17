import '../repositories/i_plant_repository.dart';

/// Use case: Delete a plant by ID
class DeletePlantUseCase {
  final IPlantRepository _repository;

  DeletePlantUseCase({required IPlantRepository repository})
      : _repository = repository;

  Future<void> call(int id) {
    return _repository.deletePlant(id);
  }
}

