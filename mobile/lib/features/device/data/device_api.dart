import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/logger.dart';
import '../../../app/config/app_config.dart';
import '../domain/device.dart';

class DeviceApi {
  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;

  DeviceApi({
    required http.Client httpClient,
    required FlutterSecureStorage secureStorage,
  })  : _httpClient = httpClient,
        _secureStorage = secureStorage;

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }

  Future<List<Device>> getAllDevices() async {
    try {
      final token = await _getToken();
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.baseUrl}/devices'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('DeviceApi.getAllDevices error', e);
      rethrow;
    }
  }

  Future<Device> getDeviceById(int id) async {
    try {
      final token = await _getToken();
      final response = await _httpClient.get(
        Uri.parse('${AppConfig.baseUrl}/devices/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Device.fromJson(data);
      } else {
        throw Exception('Failed to load device: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('DeviceApi.getDeviceById error', e);
      rethrow;
    }
  }

  Future<Device> createDevice(Device device) async {
    try {
      final token = await _getToken();
      final response = await _httpClient.post(
        Uri.parse('${AppConfig.baseUrl}/devices'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(device.toJson()),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Device.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to create device');
      }
    } catch (e) {
      AppLogger.e('DeviceApi.createDevice error', e);
      rethrow;
    }
  }

  Future<Device> updateDevice(int id, Device device) async {
    try {
      final token = await _getToken();
      final response = await _httpClient.put(
        Uri.parse('${AppConfig.baseUrl}/devices/$id'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(device.toJson()),
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Device.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update device');
      }
    } catch (e) {
      AppLogger.e('DeviceApi.updateDevice error', e);
      rethrow;
    }
  }

  Future<void> deleteDevice(int id) async {
    try {
      final token = await _getToken();
      final response = await _httpClient.delete(
        Uri.parse('${AppConfig.baseUrl}/devices/$id'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(AppConfig.apiTimeout);

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete device');
      }
    } catch (e) {
      AppLogger.e('DeviceApi.deleteDevice error', e);
      rethrow;
    }
  }
}