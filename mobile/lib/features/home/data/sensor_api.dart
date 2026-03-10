import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/utils/logger.dart';
import '../domain/models/sensor_data.dart';

class SensorApi {
  final http.Client _httpClient;
  
  // University server endpoint
  static const String _baseUrl = 'http://10.1.10.144:5000';
  static const String _dataEndpoint = '/data';

  SensorApi({required http.Client httpClient}) : _httpClient = httpClient;

  /// Fetch current sensor data from university server
  /// Returns live readings: temperature, humidity, CO2, EC, TDS, pH, light, turbidity, soil, water
  /// Includes last 10 historical readings for each sensor
  Future<SensorData> getSensorData() async {
    final uri = Uri.parse('$_baseUrl$_dataEndpoint');
    const headers = {
      'Accept': 'application/json',
      'Connection': 'close',
    };

    try {
      http.Response response;
      try {
        response = await _httpClient
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      } on http.ClientException {
        // Sensor endpoint occasionally drops the first connection from emulator.
        response = await _httpClient
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 15));
      }

      if (response.statusCode == 200) {
        AppLogger.i('Sensor data fetched successfully');
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('Invalid sensor response format');
        }
        return SensorData.fromJson(decoded);
      } else {
        throw Exception(
          'Failed to fetch sensor data: HTTP ${response.statusCode}',
        );
      }
    } on FormatException catch (e) {
      AppLogger.e('SensorApi.getSensorData parse error', e);
      throw Exception('Invalid JSON received from sensor server');
    } on http.ClientException catch (e) {
      AppLogger.e('SensorApi.getSensorData client exception', e);
      throw Exception('Network client error: ${e.message}');
    } on TimeoutException {
      const errorMessage = 'Connection timeout - sensor server may be offline';
      AppLogger.e('SensorApi.getSensorData timeout', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('SensorApi.getSensorData error', e);
      rethrow;
    }
  }
}
