import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import '../domain/models/sensor_data.dart';
import '../domain/usecases/get_real_sensor_data_use_case.dart';

/// Provider for managing home dashboard state with live sensor data
/// Polls university server every 5 seconds for real-time updates
class HomeProvider extends ChangeNotifier {
  final GetRealSensorDataUseCase _getRealSensorDataUseCase;
  Timer? _pollingTimer;

  // State
  late SensorData _sensorData;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // Getters
  SensorData get sensorData => _sensorData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  DateTime? get lastUpdated => _lastUpdated;

  // Polling interval (5 seconds)
  static const Duration _pollingInterval = Duration(seconds: 5);

  HomeProvider({required GetRealSensorDataUseCase getRealSensorDataUseCase})
      : _getRealSensorDataUseCase = getRealSensorDataUseCase {
    // Initialize with empty data
    _sensorData = _createEmptySensorData();
    // Load initial data
    loadSensorData();
    // Start polling
    _startPolling();
  }

  /// Create empty sensor data for initial state
  SensorData _createEmptySensorData() => SensorData(
        airTemperature: 0,
        airHumidity: 0,
        co2: 0,
        ec: 0,
        tds: 0,
        phLevel: 0,
        lightLevel: 0,
        turbidity: 0,
        waterTemperature: 0,
        soil1: 0,
        soil2: 0,
        soil3: 0,
        soil4: 0,
        soil5: 0,
        temperatureData: [],
        humidityData: [],
        co2Data: [],
        ecData: [],
        tdsData: [],
        turbidityData: [],
        historyDates: [],
      );

  /// Load sensor data from university server (initial load)
  Future<void> loadSensorData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _sensorData = await _getRealSensorDataUseCase();
      _lastUpdated = DateTime.now();
      AppLogger.i('Sensor data loaded: ${_sensorData.airTemperature}°C');
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('HomeProvider.loadSensorData error', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start polling university server every 5 seconds
  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (_) {
      _updateSensorData();
    });
    AppLogger.i('Sensor polling started (5 second interval)');
  }

  /// Update sensor data from university server (polling)
  Future<void> _updateSensorData() async {
    try {
      _sensorData = await _getRealSensorDataUseCase();
      _lastUpdated = DateTime.now();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('HomeProvider._updateSensorData polling error', e);
      notifyListeners();
    }
  }

  /// Manual refresh (user pulls down to refresh)
  Future<void> refreshSensorData() async {
    await loadSensorData();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    AppLogger.i('Sensor polling stopped');
    super.dispose();
  }
}

