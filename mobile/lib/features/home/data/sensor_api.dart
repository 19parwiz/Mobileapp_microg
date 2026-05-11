import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../app/config/api_config.dart';
import '../../../core/utils/logger.dart';
import '../domain/models/sensor_data.dart';

/// Talks to the sensor service exposed at the public HTTPS URL
/// (VPS reverse proxy -> WireGuard tunnel -> lab Pi). One job: fetch
/// live readings from `/data`.
class SensorApi {
  final http.Client _httpClient;

  static const String _dataEndpoint = '/data';
  static const Duration _requestTimeout = Duration(seconds: 15);

  SensorApi({required http.Client httpClient}) : _httpClient = httpClient {
    // Print which tunnel the app is about to use. Makes "why no sensors?"
    // questions a one-line log lookup instead of a guessing game.
    AppLogger.i(
      '[SENSOR] Tunnel target: ${ApiConfig.sensorServiceUrl} '
      '(${ApiConfig.sensorServiceSource})',
    );
  }

  /// Fetches the current sensor snapshot plus the last 10 historical readings.
  /// Throws on timeout, network failure, non-200, or malformed JSON.
  Future<SensorData> getSensorData() async {
    final uri = Uri.parse('${ApiConfig.sensorServiceUrl}$_dataEndpoint');
    const headers = {
      'Accept': 'application/json',
      'Connection': 'close',
    };
    final stopwatch = Stopwatch()..start();

    try {
      AppLogger.d('[SENSOR] GET $uri');

      // Emulators sometimes drop the very first connection through a tunnel,
      // so we retry once before giving up.
      http.Response response;
      try {
        response = await _httpClient
            .get(uri, headers: headers)
            .timeout(_requestTimeout);
      } on http.ClientException catch (e) {
        AppLogger.w('[SENSOR] First attempt dropped (${e.message}), retrying once');
        response = await _httpClient
            .get(uri, headers: headers)
            .timeout(_requestTimeout);
      }

      stopwatch.stop();
      final ms = stopwatch.elapsedMilliseconds;

      if (response.statusCode != 200) {
        AppLogger.e(
          '[SENSOR] Tunnel returned HTTP ${response.statusCode} in ${ms}ms '
          '-> ${_excerpt(response.body)}',
        );
        throw Exception(
          'Failed to fetch sensor data: HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        AppLogger.e('[SENSOR] Unexpected payload shape: ${decoded.runtimeType}');
        throw Exception('Invalid sensor response format');
      }

      AppLogger.i(
        '[SENSOR] Snapshot OK in ${ms}ms (${response.bodyBytes.length} bytes)',
      );
      return SensorData.fromJson(decoded);
    } on FormatException catch (e) {
      AppLogger.e('[SENSOR] JSON parse failed for $uri', e);
      throw Exception('Invalid JSON received from sensor server');
    } on http.ClientException catch (e) {
      // Almost always means the tunnel is down or the laptop is offline.
      AppLogger.e('[SENSOR] Network error talking to ${uri.host}: ${e.message}');
      throw Exception('Network client error: ${e.message}');
    } on TimeoutException {
      const msg = 'Connection timeout - sensor server may be offline';
      AppLogger.e('[SENSOR] Timed out after ${_requestTimeout.inSeconds}s on ${uri.host}');
      throw Exception(msg);
    } catch (e) {
      AppLogger.e('[SENSOR] Unexpected failure on $uri', e);
      rethrow;
    }
  }

  // Trim long error bodies so we don't dump a whole HTML page into logs.
  String _excerpt(String body, {int max = 200}) {
    final trimmed = body.trim();
    if (trimmed.length <= max) return trimmed;
    return '${trimmed.substring(0, max)}...';
  }
}
