import 'package:dio/dio.dart';
import '../../../core/utils/logger.dart';
import '../domain/entities/Plant.dart';

/// PlantApi class for making HTTP requests to the backend plant API
class PlantApi {
  final Dio _dio;

  PlantApi({required Dio dio}) : _dio = dio;

  /// Get all plants for the current user
  Future<List<Plant>> getAllPlants() async {
    try {
      final response = await _dio.get('/plants');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Plant.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plants: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('PlantApi.getAllPlants DioException', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('PlantApi.getAllPlants error', e);
      rethrow;
    }
  }

  /// Get plant by ID
  Future<Plant> getPlantById(int id) async {
    try {
      final response = await _dio.get('/plants/$id');

      if (response.statusCode == 200) {
        return Plant.fromJson(response.data);
      } else {
        throw Exception('Failed to load plant: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('PlantApi.getPlantById DioException', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('PlantApi.getPlantById error', e);
      rethrow;
    }
  }

  /// Create a new plant
  Future<Plant> createPlant(Plant plant) async {
    try {
      final response = await _dio.post(
        '/plants',
        data: plant.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Plant.fromJson(response.data);
      } else {
        throw Exception('Failed to create plant: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('PlantApi.createPlant DioException: $errorMessage', e);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('PlantApi.createPlant error', e);
      rethrow;
    }
  }

  /// Update an existing plant
  Future<Plant> updatePlant(int id, Plant plant) async {
    try {
      final response = await _dio.put(
        '/plants/$id',
        data: plant.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Plant.fromJson(response.data);
      } else {
        throw Exception('Failed to update plant: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('PlantApi.updatePlant DioException', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('PlantApi.updatePlant error', e);
      rethrow;
    }
  }

  /// Delete a plant
  Future<void> deletePlant(int id) async {
    try {
      final response = await _dio.delete('/plants/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete plant: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('PlantApi.deletePlant DioException', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('PlantApi.deletePlant error', e);
      rethrow;
    }
  }

  /// Extract error message from DioException
  String _extractErrorMessage(DioException e) {
    if (e.response?.data != null) {
      if (e.response!.data is Map && e.response!.data['message'] != null) {
        return e.response!.data['message'];
      }
      return e.response!.data.toString();
    }
    return e.message ?? 'Network error occurred';
  }
}
