import 'package:dio/dio.dart';
import '../../../core/utils/logger.dart';
import '../../../app/config/api_config.dart';
import '../domain/device.dart';

class DeviceApi {
  final Dio _dio;

  DeviceApi({required Dio dio}) : _dio = dio;

  Future<List<Device>> getAllDevices() async {
    try {
      final response = await _dio.get('/devices');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('DeviceApi.getAllDevices DioException', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('DeviceApi.getAllDevices error', e);
      rethrow;
    }
  }

  Future<Device> getDeviceById(int id) async {
    try {
      final response = await _dio.get('/devices/$id');

      if (response.statusCode == 200) {
        return Device.fromJson(response.data);
      } else {
        throw Exception('Failed to load device: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('DeviceApi.getDeviceById DioException', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('DeviceApi.getDeviceById error', e);
      rethrow;
    }
  }

  Future<Device> createDevice(Device device) async {
    try {
      final response = await _dio.post(
        '/devices',
        data: device.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Device.fromJson(response.data);
      } else {
        throw Exception('Failed to create device: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('DeviceApi.createDevice DioException: $errorMessage', e);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('DeviceApi.createDevice error', e);
      rethrow;
    }
  }

  Future<Device> updateDevice(int id, Device device) async {
    try {
      final response = await _dio.put(
        '/devices/$id',
        data: device.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Device.fromJson(response.data);
      } else {
        throw Exception('Failed to update device: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('DeviceApi.updateDevice DioException', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('DeviceApi.updateDevice error', e);
      rethrow;
    }
  }

  Future<void> deleteDevice(int id) async {
    try {
      final response = await _dio.delete(
        '/devices/$id',
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete device: ${response.statusCode}');
      }
    } on DioException catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.e('DeviceApi.deleteDevice DioException', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('DeviceApi.deleteDevice error', e);
      rethrow;
    }
  }

  /// Extracts human-readable error message from DioException
  /// Handles backend error responses, network errors, and timeouts
  String _extractErrorMessage(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final responseData = e.response!.data;
      
      // Try to extract message from error response
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('message')) {
          return '${responseData['message']} (HTTP $statusCode)';
        }
        if (responseData.containsKey('error')) {
          return '${responseData['error']} (HTTP $statusCode)';
        }
      }
      
      // Fallback to status text
      return '${e.response!.statusMessage} (HTTP $statusCode)';
    }
    
    // Network errors
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout - backend server may be offline';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Receive timeout - backend server not responding';
    }
    if (e.type == DioExceptionType.sendTimeout) {
      return 'Send timeout - unable to reach backend server';
    }
    
    return 'Network error: ${e.message}';
  }
}

