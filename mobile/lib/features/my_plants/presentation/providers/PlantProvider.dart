import 'package:flutter/foundation.dart';
import '../../domain/entities/Plant.dart';
import '../../domain/usecases/get_plants_use_case.dart';
import '../../domain/usecases/add_plant_use_case.dart';
import '../../domain/usecases/update_plant_use_case.dart';
import '../../domain/usecases/delete_plant_use_case.dart';

/// Provider for managing plant state
/// Follows clean architecture: depends only on use cases (domain layer)
class PlantProvider extends ChangeNotifier {
  final GetPlantsUseCase _getPlantsUseCase;
  final AddPlantUseCase _addPlantUseCase;
  final UpdatePlantUseCase _updatePlantUseCase;
  final DeletePlantUseCase _deletePlantUseCase;

  List<Plant> _plants = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Plant> get plants => _plants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  int get plantCount => _plants.length;

  PlantProvider({
    required GetPlantsUseCase getPlantsUseCase,
    required AddPlantUseCase addPlantUseCase,
    required UpdatePlantUseCase updatePlantUseCase,
    required DeletePlantUseCase deletePlantUseCase,
  })  : _getPlantsUseCase = getPlantsUseCase,
        _addPlantUseCase = addPlantUseCase,
        _updatePlantUseCase = updatePlantUseCase,
        _deletePlantUseCase = deletePlantUseCase;

  /// Fetch plants using use case
  Future<void> fetchPlants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plants = await _getPlantsUseCase();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load plants: $e';
      debugPrint('Error fetching plants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new plant using use case
  Future<void> addPlant(Plant plant) async {
    try {
      final newPlant = await _addPlantUseCase(plant);
      _plants.add(newPlant);
      _errorMessage = null;
      notifyListeners();
      debugPrint('Plant added: ${newPlant.name}');
    } catch (e) {
      _errorMessage = 'Failed to add plant: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update an existing plant using use case
  Future<void> updatePlant(Plant plant) async {
    try {
      final updatedPlant = await _updatePlantUseCase(plant);
      final index = _plants.indexWhere((p) => p.id == plant.id);
      if (index != -1) {
        _plants[index] = updatedPlant;
      }
      _errorMessage = null;
      notifyListeners();
      debugPrint('Plant updated: ${plant.name}');
    } catch (e) {
      _errorMessage = 'Failed to update plant: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a plant using use case
  Future<void> deletePlant(int id) async {
    try {
      await _deletePlantUseCase(id);
      _plants.removeWhere((p) => p.id == id);
      _errorMessage = null;
      notifyListeners();
      debugPrint('Plant deleted: id=$id');
    } catch (e) {
      _errorMessage = 'Failed to delete plant: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get plant by ID
  Plant? getPlantById(int id) {
    try {
      return _plants.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh plants list
  Future<void> refresh() async {
    await fetchPlants();
  }
}
