import 'dart:async';
import 'package:flutter/foundation.dart';
import '../domain/sensor_data.dart';
import '../domain/usecases/get_sensor_data_use_case.dart';

/// Provider for managing home dashboard state
class HomeProvider extends ChangeNotifier {
  final GetSensorDataUseCase _getSensorDataUseCase;
  Timer? _updateTimer;
  
  List<SensorData> _sensorData = [];
  List<SensorData> _chartData = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<SensorData> get sensorData => _sensorData;
  List<SensorData> get chartData => _chartData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  HomeProvider({required GetSensorDataUseCase getSensorDataUseCase})
      : _getSensorDataUseCase = getSensorDataUseCase {
    _initializeData();
    // Auto-update disabled for now - will be enabled when real sensors are connected
    // Update frequency will be hourly/daily based on real sensor requirements
    // _startAutoUpdate();
  }

  /// Initialize sensor data
  void _initializeData() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final result = _getSensorDataUseCase(refresh: true, hours: 24);
      _sensorData = result.sensorData;
      _chartData = result.chartData;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load sensor data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start automatic data updates (disabled for now - will be hourly/daily when real sensors are connected)
  void _startAutoUpdate() {
    // Disabled: Updates every 5 seconds was too frequent
    // When real sensors are connected, update hourly or daily
    // _updateTimer = Timer.periodic(const Duration(hours: 1), (timer) {
    //   updateSensorData();
    // });
  }

  /// Update sensor data with new random values
  void updateSensorData() {
    debugPrint('Updating sensor data...');
    try {
      _errorMessage = null;
      final result = _getSensorDataUseCase(refresh: true, hours: 24);
      _sensorData = result.sensorData;
      _chartData = result.chartData;
      debugPrint('Sensor data updated: ${_sensorData.length} sensors, ${_chartData.length} chart points');
    } catch (e) {
      _errorMessage = 'Failed to update sensor data: $e';
      debugPrint('Error updating sensor data: $e');
    }
    notifyListeners();
  }

  /// Get sensor data by type
  SensorData? getSensorByType(String type) {
    try {
      return _sensorData.firstWhere((data) => data.sensorType == type);
    } catch (e) {
      return null;
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}

