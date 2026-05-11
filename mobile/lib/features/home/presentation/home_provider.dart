import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';
import '../domain/models/sensor_data.dart';
import '../domain/usecases/get_real_sensor_data_use_case.dart';

/// Holds the home dashboard state and polls the sensor service every 5s.
/// All network calls go through [GetRealSensorDataUseCase] -> [SensorApi].
class HomeProvider extends ChangeNotifier {
  final GetRealSensorDataUseCase _getRealSensorDataUseCase;
  Timer? _pollingTimer;

  late SensorData _sensorData;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // Tracks the previous poll outcome so we only log on state transitions
  // (good -> bad or bad -> good) instead of every 5 seconds.
  bool _lastPollOk = false;

  SensorData get sensorData => _sensorData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  DateTime? get lastUpdated => _lastUpdated;

  static const Duration _pollingInterval = Duration(seconds: 5);

  HomeProvider({required GetRealSensorDataUseCase getRealSensorDataUseCase})
      : _getRealSensorDataUseCase = getRealSensorDataUseCase {
    _sensorData = _createEmptySensorData();
    loadSensorData();
    _startPolling();
  }

  /// Zeroed snapshot so the UI has something to render before the first fetch.
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

  /// First load triggered from the constructor and from pull-to-refresh.
  /// Surfaces loading + error state to the UI.
  Future<void> loadSensorData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    AppLogger.i('[SENSOR] Initial load starting');
    try {
      _sensorData = await _getRealSensorDataUseCase();
      _lastUpdated = DateTime.now();
      _lastPollOk = true;
      AppLogger.i(
        '[SENSOR] Dashboard loaded: ${_sensorData.airTemperature}°C, '
        '${_sensorData.airHumidity}%',
      );
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _lastPollOk = false;
      AppLogger.e('[SENSOR] Initial load failed', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(_pollingInterval, (_) => _updateSensorData());
    AppLogger.i('[SENSOR] Polling every ${_pollingInterval.inSeconds}s');
  }

  /// Background poll. We keep these logs quiet: a per-tick line at debug
  /// level, and an info/warn line only when the OK<->error state flips.
  Future<void> _updateSensorData() async {
    try {
      _sensorData = await _getRealSensorDataUseCase();
      _lastUpdated = DateTime.now();
      _errorMessage = null;

      AppLogger.d(
        '[SENSOR] Poll OK ${_sensorData.airTemperature}°C / '
        '${_sensorData.airHumidity}%',
      );
      if (!_lastPollOk) {
        AppLogger.i('[SENSOR] Tunnel recovered, polling healthy again');
      }
      _lastPollOk = true;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (_lastPollOk) {
        AppLogger.w('[SENSOR] Poll failed (was healthy): $_errorMessage');
      } else {
        AppLogger.d('[SENSOR] Poll still failing: $_errorMessage');
      }
      _lastPollOk = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh entry point.
  Future<void> refreshSensorData() async {
    AppLogger.i('[SENSOR] Manual refresh requested');
    await loadSensorData();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    AppLogger.i('[SENSOR] Polling stopped');
    super.dispose();
  }
}
