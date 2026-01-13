import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/device.dart';
import '../../domain/repositories/device_repository.dart';
import '../../config/api_config.dart';
import '../../config/app_config.dart';
import '../../../core/utils/logger.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final http.Client _httpClient;
  final FlutterSecureStorage _secureStorage;

  DeviceRepositoryImpl({
    required http.Client httpClient,
    required FlutterSecureStorage secureStorage,
  })  : _httpClient = httpClient,
        _secureStorage = secureStorage;

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: AppConfig.tokenKey);
  }

  Map<String, String> _headers(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    return headers;
  }

  @override
  Future<Device> createDevice(Device device) async {
    final token = await _getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/devices');
    AppLogger.d('POST $uri -> ${device.toJson()}');

    final response = await _httpClient.post(
      uri,
      headers: _headers(token),
      body: jsonEncode(device.toJson()),
    ).timeout(AppConfig.apiTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Device.fromJson(data);
    }

    AppLogger.e('Create device failed: ${response.statusCode} ${response.body}');
    throw Exception('Create device failed');
  }

  @override
  Future<void> deleteDevice(String id) async {
    final token = await _getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/devices/$id');
    AppLogger.d('DELETE $uri');

    final response = await _httpClient.delete(
      uri,
      headers: _headers(token),
    ).timeout(AppConfig.apiTimeout);

    if (response.statusCode != 200 && response.statusCode != 204) {
      AppLogger.e('Delete device failed: ${response.statusCode} ${response.body}');
      throw Exception('Delete device failed');
    }
  }

  @override
  Future<Device?> getDeviceById(String id) async {
    final token = await _getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/devices/$id');
    AppLogger.d('GET $uri');

    final response = await _httpClient.get(uri, headers: _headers(token)).timeout(AppConfig.apiTimeout);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Device.fromJson(data);
    }

    if (response.statusCode == 404) return null;
    AppLogger.e('Get device failed: ${response.statusCode} ${response.body}');
    throw Exception('Get device failed');
  }

  @override
  Future<List<Device>> getDevices() async {
    final token = await _getToken();
    final uri = Uri.parse('${ApiConfig.baseUrl}/devices');
    AppLogger.d('GET $uri');

    final response = await _httpClient.get(uri, headers: _headers(token)).timeout(AppConfig.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List<dynamic>;
      return data.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
    }

    AppLogger.e('Get devices failed: ${response.statusCode} ${response.body}');
    throw Exception('Get devices failed');
  }

  @override
  Future<Device> updateDevice(Device device) async {
    final token = await _getToken();
    if (device.id == null) throw Exception('Device id is required for update');
    final uri = Uri.parse('${ApiConfig.baseUrl}/devices/${device.id}');
    AppLogger.d('PUT $uri -> ${device.toJson()}');

    final response = await _httpClient.put(
      uri,
      headers: _headers(token),
      body: jsonEncode(device.toJson()),
    ).timeout(AppConfig.apiTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Device.fromJson(data);
    }

    AppLogger.e('Update device failed: ${response.statusCode} ${response.body}');
    throw Exception('Update device failed');
  }
}
