import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Platform-aware API base URL helper.
///
/// - Android emulator uses 10.0.2.2
/// - iOS/macOS/simulator uses localhost
/// - Web uses localhost by default
class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080/api';
      // iOS, macOS, Linux, Windows use localhost by default
      return 'http://localhost:8080/api';
    } catch (_) {
      // Fallback when Platform is not available
      return 'http://localhost:8080/api';
    }
  }
}
