class AppConfig {
  static const String appName = 'Microgreens Management';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  // TODO: Update with actual backend URL
  static const String baseUrl = 'http://localhost:8080/api';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  
  // MQTT Configuration
  // TODO: Configure MQTT broker URL and credentials
  static const String mqttBroker = 'mqtt://localhost:1883';
  static const String mqttClientId = 'microgreens_mobile_app';
  
  // WebSocket Configuration
  // TODO: Configure WebSocket URL
  static const String websocketUrl = 'ws://localhost:8080/ws';
  
  // Environment
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  static const bool enableLogging = !isProduction;
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}

