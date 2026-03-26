import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/config/api_config.dart';
import '../../../core/utils/logger.dart';
import '../domain/models/sensor_data.dart';

class SensorApi {
  final http.Client _httpClient;

  static const String _dataEndpoint = '/data';

  SensorApi({required http.Client httpClient}) : _httpClient = httpClient;

  /// Fetch current sensor data from university server
  /// Returns live readings: temperature, humidity, CO2, EC, TDS, pH, light, turbidity, soil, water
  /// Includes last 10 historical readings for each sensor
  Future<SensorData> getSensorData() async {
    final uri = Uri.parse('${ApiConfig.sensorServiceUrl}$_dataEndpoint');
    const headers = {
      'Accept': 'application/json',
      'Connection': 'close',
    };

    try {
      AppLogger.i('[SENSOR] Requesting live sensor data');
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
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is! Map<String, dynamic>) {
          throw Exception('Invalid sensor response format');
        }
        AppLogger.i('[SENSOR] Live sensor data updated');
        return SensorData.fromJson(decoded);
      } else {
        throw Exception(
          'Failed to fetch sensor data: HTTP ${response.statusCode}',
        );
      }
    } on FormatException catch (e) {
      AppLogger.e('[SENSOR] Invalid response format', e);
      throw Exception('Invalid JSON received from sensor server');
    } on http.ClientException catch (e) {
      AppLogger.e('[SENSOR] Network client error', e);
      throw Exception('Network client error: ${e.message}');
    } on TimeoutException {
      const errorMessage = 'Connection timeout - sensor server may be offline';
      AppLogger.e('[SENSOR] Request timeout', errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.e('[SENSOR] Request failed', e);
      rethrow;
    }
  }
}
