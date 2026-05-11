import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Environments:
  //   local  -> everything on this machine
  //   campus -> backend on laptop, remote services on lab host
  //   vpn    -> backend on laptop, remote services via VPN
  // Override at run time, e.g.
  //   flutter run --dart-define=APP_ENV=vpn --dart-define=REMOTE_HOST=10.1.10.144
  static const String _environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'railway',
  );
  static const String _apiHostOverride = String.fromEnvironment('API_HOST');
  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');
  static const String _aiHostOverride = String.fromEnvironment('AI_HOST');
  static const String _sensorHostOverride =
      String.fromEnvironment('SENSOR_HOST');
  static const String _sensorBaseUrlOverride = String.fromEnvironment(
    'SENSOR_BASE_URL',
  );
  static const String _remoteHostOverride =
      String.fromEnvironment('REMOTE_HOST');
  static const String _cameraHostOverride =
      String.fromEnvironment('CAMERA_HOST');
  static const String _cameraBaseUrlOverride = String.fromEnvironment(
    'CAMERA_BASE_URL',
  );
  static const String _railwayBaseUrl =
      'https://mobileappmicrog-production.up.railway.app/api';

  // Stable public HTTPS endpoints proxied through the VPS (Nginx + WireGuard)
  // to the lab Pi. To migrate to a real domain later, just change these two
  // constants and rebuild.
  static const String _defaultSensorBaseUrl =
      'https://sensors.178-88-115-9.nip.io';
  static const String _defaultCameraBaseUrl =
      'https://cam.178-88-115-9.nip.io';

  static String _defaultHostForPlatform() {
    if (kIsWeb) return 'localhost';
    if (Platform.isAndroid)
      return '10.0.2.2'; // Android emulator -> host machine
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
      if (_apiBaseUrlOverride.isNotEmpty) {
        return _apiBaseUrlOverride;
      }

      // For deployed app builds, allow a simple environment switch to Railway.
      if (_environment.toLowerCase() == 'production' ||
          _environment.toLowerCase() == 'railway') {
        return _railwayBaseUrl;
      }

      final host = _apiHostOverride.isNotEmpty
          ? _apiHostOverride
          : (_environment.toLowerCase() == 'local'
              ? _defaultHostForPlatform()
              : remoteHost);
      return 'http://$host:8081/api';
    } catch (_) {
      return 'http://localhost:8081/api';
    }
  }

  static String get aiServiceUrl {
    try {
      final host = _aiHostOverride.isNotEmpty ? _aiHostOverride : remoteHost;
      return 'http://$host:5000';
    } catch (_) {
      return 'http://localhost:5000';
    }
  }

  // Camera base URL resolution.
  // Default: VPS-proxied HTTPS (https://cam.178-88-115-9.nip.io) with
  //   `/hls/<stream>/...` and `/mjpeg/<stream>/...` path prefixes.
  // Override examples (for direct-LAN dev only):
  //   --dart-define=CAMERA_BASE_URL=https://cam.example.com
  //   --dart-define=CAMERA_HOST=10.1.10.144   (legacy LAN mode: ports 8888/8889 direct)
  static String get cameraBaseUrl {
    if (_cameraBaseUrlOverride.isNotEmpty) {
      return _cameraBaseUrlOverride.endsWith('/')
          ? _cameraBaseUrlOverride.substring(
              0,
              _cameraBaseUrlOverride.length - 1,
            )
          : _cameraBaseUrlOverride;
    }
    return _defaultCameraBaseUrl;
  }

  // CAMERA_HOST is the legacy LAN-direct override (no VPS proxy). When set,
  // HLS comes from :8888 and MJPEG from :8889 directly on that host.
  static String get cameraHlsBaseUrl {
    if (_cameraHostOverride.isNotEmpty) {
      return 'http://$_cameraHostOverride:8888';
    }
    return '$cameraBaseUrl/hls';
  }

  static String get cameraMjpegBaseUrl {
    if (_cameraHostOverride.isNotEmpty) {
      return 'http://$_cameraHostOverride:8889';
    }
    return '$cameraBaseUrl/mjpeg';
  }

  static String cameraHlsUrl(String streamPath) =>
      '$cameraHlsBaseUrl/$streamPath';

  static String cameraMjpegUrl(String streamPath) =>
      '$cameraMjpegBaseUrl/$streamPath';

  // Sensor service URL resolution.
  // Default: VPS-proxied HTTPS (https://sensors.178-88-115-9.nip.io).
  // Override examples (for direct-LAN dev):
  //   --dart-define=SENSOR_BASE_URL=https://sensors.example.com
  //   --dart-define=SENSOR_HOST=10.1.10.144   (legacy: port 5000 direct on LAN)
  static String get sensorServiceUrl {
    try {
      if (_sensorBaseUrlOverride.isNotEmpty) {
        return _sensorBaseUrlOverride.endsWith('/')
            ? _sensorBaseUrlOverride.substring(
                0,
                _sensorBaseUrlOverride.length - 1,
              )
            : _sensorBaseUrlOverride;
      }
      if (_sensorHostOverride.isNotEmpty) {
        return 'http://$_sensorHostOverride:5000';
      }
      return _defaultSensorBaseUrl;
    } catch (_) {
      return _defaultSensorBaseUrl;
    }
  }

  // Human-friendly tag describing where the sensor URL came from.
  // Useful in startup logs so you instantly know which endpoint you're hitting.
  static String get sensorServiceSource {
    if (_sensorBaseUrlOverride.isNotEmpty) return 'override:SENSOR_BASE_URL';
    if (_sensorHostOverride.isNotEmpty) return 'override:SENSOR_HOST';
    return 'default:VPS-proxy(nip.io)';
  }
}
