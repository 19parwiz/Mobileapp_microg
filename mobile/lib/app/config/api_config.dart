import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Optional overrides, e.g. --dart-define=API_HOST=10.200.1.106 --dart-define=AI_HOST=10.200.1.106
  static const String _apiHostOverride = String.fromEnvironment('API_HOST');
  static const String _aiHostOverride = String.fromEnvironment('AI_HOST');

  static String _defaultHostForPlatform() {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2'; // Android emulator -> host machine
    return 'localhost';
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
          : _defaultHostForPlatform();
      return 'http://$host:5000';
    } catch (_) {
      return 'http://localhost:5000';
    }
  }

  // Sensor service shares the same endpoint as AI service in the current setup.
  static String get sensorServiceUrl => aiServiceUrl;
}