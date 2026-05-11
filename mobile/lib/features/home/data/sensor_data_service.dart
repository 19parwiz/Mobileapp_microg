import 'dart:math';
import '../../../core/utils/logger.dart';
import '../domain/sensor_data.dart';

/// Mock sensor source kept around for offline/demo screens.
/// The real dashboard uses [SensorApi] -> [RealSensorRepositoryImpl] instead.
class SensorDataService {
  final Random _random = Random();
  final List<SensorData> _historicalData = [];

  // Last generated values; serve as the "current reading" snapshot.
  double _temperature = 24.5;
  double _humidity = 65.0;
  double _light = 850.0;

  SensorData getTemperature() {
    return SensorData(
      sensorType: 'temperature',
      value: _temperature,
      unit: '°C',
      timestamp: DateTime.now(),
      trend: _getTrend(_temperature, 20.0, 25.0),
    );
  }

  SensorData getHumidity() {
    return SensorData(
      sensorType: 'humidity',
      value: _humidity,
      unit: '%',
      timestamp: DateTime.now(),
      trend: _getTrend(_humidity, 60.0, 70.0),
    );
  }

  SensorData getLight() {
    return SensorData(
      sensorType: 'light',
      value: _light,
      unit: 'lux',
      timestamp: DateTime.now(),
      trend: _getTrend(_light, 500.0, 1000.0),
    );
  }

  List<SensorData> getAllSensors() {
    return [getTemperature(), getHumidity(), getLight()];
  }

  /// Roll a new random snapshot. NOT real sensor data — purely for demos
  /// and widget catalogues.
  void generateRandomData() {
    _temperature = double.parse(
      (18.0 + _random.nextDouble() * 10.0).toStringAsFixed(1),
    );
    _humidity = double.parse(
      (50.0 + _random.nextDouble() * 30.0).toStringAsFixed(1),
    );
    _light = double.parse(
      (300.0 + _random.nextDouble() * 900.0).toStringAsFixed(0),
    );

    AppLogger.d(
      '[SENSOR][MOCK] New random snapshot: '
      'temp=${_temperature}°C humidity=$_humidity% light=${_light}lux',
    );

    _historicalData.addAll(getAllSensors());

    // Cap history at ~24h (1440 readings at 1/min) so we don't grow forever.
    if (_historicalData.length > 1440) {
      _historicalData.removeRange(0, _historicalData.length - 1440);
    }
  }

  /// Returns history for charts. If we don't have enough yet, backfill it.
  List<SensorData> getHistoricalData({
    int hours = 24,
    String? sensorType,
  }) {
    final cutoffTime = DateTime.now().subtract(Duration(hours: hours));

    var filtered = _historicalData.where((data) {
      final matchesType = sensorType == null || data.sensorType == sensorType;
      final isRecent = data.timestamp.isAfter(cutoffTime);
      return matchesType && isRecent;
    }).toList();

    if (filtered.length < 10) {
      _generateHistoricalData(hours: hours, sensorType: sensorType);
      return getHistoricalData(hours: hours, sensorType: sensorType);
    }

    return filtered;
  }

  /// Backfill: builds a fake series at 5-minute steps over the requested window.
  void _generateHistoricalData({required int hours, String? sensorType}) {
    final now = DateTime.now();
    final baseValues = {
      'temperature': 24.0,
      'humidity': 65.0,
      'light': 850.0,
    };

    for (int i = hours * 60; i >= 0; i -= 5) {
      final timestamp = now.subtract(Duration(minutes: i));
      final variation = (_random.nextDouble() - 0.5) * 2.0;

      if (sensorType == null || sensorType == 'temperature') {
        final value = baseValues['temperature']! + variation * 3;
        _historicalData.add(SensorData(
          sensorType: 'temperature',
          value: double.parse(value.toStringAsFixed(1)),
          unit: '°C',
          timestamp: timestamp,
        ));
      }

      if (sensorType == null || sensorType == 'humidity') {
        final value = baseValues['humidity']! + variation * 5;
        _historicalData.add(SensorData(
          sensorType: 'humidity',
          value: double.parse(value.toStringAsFixed(1)),
          unit: '%',
          timestamp: timestamp,
        ));
      }

      if (sensorType == null || sensorType == 'light') {
        final value = baseValues['light']! + variation * 100;
        _historicalData.add(SensorData(
          sensorType: 'light',
          value: double.parse(value.toStringAsFixed(0)),
          unit: 'lux',
          timestamp: timestamp,
        ));
      }
    }

    AppLogger.d(
      '[SENSOR][MOCK] Backfilled ${_historicalData.length} historical points '
      '(window=${hours}h, type=${sensorType ?? 'all'})',
    );
  }

  /// Compares against a noisy "previous" value, so the UI sees an arrow
  /// even on the first tick.
  TrendDirection? _getTrend(double value, double minOptimal, double maxOptimal) {
    final previousValue = _getPreviousValue(value);
    if (previousValue == null) return TrendDirection.stable;

    if (value > previousValue) return TrendDirection.up;
    if (value < previousValue) return TrendDirection.down;
    return TrendDirection.stable;
  }

  double? _getPreviousValue(double currentValue) {
    return currentValue + (_random.nextDouble() - 0.5) * 2.0;
  }
}
