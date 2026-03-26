import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Named environments:
  // - local: backend and remote services run on the same machine as Flutter
  // - campus: backend runs on the laptop, remote services run on the lab host
  // - vpn: backend runs on the laptop, remote services run through the VPN
  //
  // Useful examples:
  // flutter run --dart-define=APP_ENV=campus
  // flutter run --dart-define=APP_ENV=vpn --dart-define=REMOTE_HOST=10.1.10.144
  static const String _environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'campus',
  );
  static const String _apiHostOverride = String.fromEnvironment('API_HOST');
  static const String _aiHostOverride = String.fromEnvironment('AI_HOST');
  static const String _remoteHostOverride = String.fromEnvironment('REMOTE_HOST');
  static const String _cameraHostOverride = String.fromEnvironment('CAMERA_HOST');

  static String _defaultHostForPlatform() {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2'; // Android emulator -> host machine
    return 'localhost';
  }

  static String _defaultRemoteHostForEnvironment() {
    switch (_environment.toLowerCase()) {
      case 'local':
        return _defaultHostForPlatform();
      case 'campus':
      case 'vpn':
        return '10.1.10.144';
      default:
        return '10.1.10.144';
    }
  }

  static String get environmentName => _environment;

  static String get remoteHost {
    if (_remoteHostOverride.isNotEmpty) return _remoteHostOverride;
    return _defaultRemoteHostForEnvironment();
  }

  static String get cameraHost {
    if (_cameraHostOverride.isNotEmpty) return _cameraHostOverride;
    return remoteHost;
  }

  static String get baseUrl {
    try {
      final host = _apiHostOverride.isNotEmpty
          ? _apiHostOverride
          : _defaultHostForPlatform();
      return 'http://$host:8080/api';
    } catch (_) {
      return 'http://localhost:8080/api';
    }
  }

  static String get aiServiceUrl {
    try {
      final host = _aiHostOverride.isNotEmpty
          ? _aiHostOverride
          : remoteHost;
      return 'http://$host:5000';
    } catch (_) {
      return 'http://localhost:5000';
    }
  }

  static String get cameraHlsBaseUrl => 'http://$cameraHost:8888';

  static String get cameraMjpegBaseUrl => 'http://$cameraHost:8889';

  static String cameraHlsUrl(String streamPath) =>
      '$cameraHlsBaseUrl/$streamPath';

  static String cameraMjpegUrl(String streamPath) =>
      '$cameraMjpegBaseUrl/$streamPath';

  // Sensor service shares the same endpoint as AI service in the current setup.
  static String get sensorServiceUrl => aiServiceUrl;
}