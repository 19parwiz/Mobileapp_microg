  import 'dart:math';
import '../domain/sensor_data.dart';

/// Service for managing sensor data with mock/random data generation
class SensorDataService {
  final Random _random = Random();
  final List<SensorData> _historicalData = [];
  
  // Current sensor values
  double _temperature = 24.5;
  double _humidity = 65.0;
  double _light = 850.0;

  /// Get current temperature reading
  SensorData getTemperature() {
    return SensorData(
      sensorType: 'temperature',
      value: _temperature,
      unit: '°C',
      timestamp: DateTime.now(),
      trend: _getTrend(_temperature, 20.0, 25.0),
    );
  }

  /// Get current humidity reading
  SensorData getHumidity() {
    return SensorData(
      sensorType: 'humidity',
      value: _humidity,
      unit: '%',
      timestamp: DateTime.now(),
      trend: _getTrend(_humidity, 60.0, 70.0),
    );
  }

  /// Get current light reading
  SensorData getLight() {
    return SensorData(
      sensorType: 'light',
      value: _light,
      unit: 'lux',
      timestamp: DateTime.now(),
      trend: _getTrend(_light, 500.0, 1000.0),
    );
  }

  /// Get all current sensor readings
  List<SensorData> getAllSensors() {
    return [
      getTemperature(),
      getHumidity(),
      getLight(),
    ];
  }

  /// Generate random sensor data for demo purposes
  /// NOTE: This is MOCK DATA - no real sensors are connected!
  /// Data is generated randomly for testing/demo purposes only.
  void generateRandomData() {
    // Temperature: 18-28°C
    _temperature = 18.0 + _random.nextDouble() * 10.0;
    _temperature = double.parse(_temperature.toStringAsFixed(1));
    
    // Humidity: 50-80%
    _humidity = 50.0 + _random.nextDouble() * 30.0;
    _humidity = double.parse(_humidity.toStringAsFixed(1));
    
    // Light: 300-1200 lux
    _light = 300.0 + _random.nextDouble() * 900.0;
    _light = double.parse(_light.toStringAsFixed(0));
    
    // Log to console where data is coming from
    print('📊 [SensorDataService] Generating MOCK sensor data:');
    print('   🌡️  Temperature: $_temperature°C (MOCK - Random: 18-28°C)');
    print('   💧 Humidity: $_humidity% (MOCK - Random: 50-80%)');
    print('   💡 Light: $_light lux (MOCK - Random: 300-1200 lux)');
    print('   ⚠️  WARNING: No real sensors connected! This is simulated data.');
    
    // Add to historical data
    _historicalData.addAll(getAllSensors());
    
    // Keep only last 24 hours of data (assuming 1 reading per minute = 1440 readings)
    if (_historicalData.length > 1440) {
      _historicalData.removeRange(0, _historicalData.length - 1440);
    }
  }

  /// Get historical data for charts (last N hours)
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
    
    // If not enough historical data, generate some
    if (filtered.length < 10) {
      _generateHistoricalData(hours: hours, sensorType: sensorType);
      return getHistoricalData(hours: hours, sensorType: sensorType);
    }
    
    return filtered;
  }

  /// Generate historical data for charts
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
  }

  /// Determine trend direction based on value and optimal range
  TrendDirection? _getTrend(double value, double minOptimal, double maxOptimal) {
    final previousValue = _getPreviousValue(value);
    if (previousValue == null) return TrendDirection.stable;
    
    if (value > previousValue) {
      return TrendDirection.up;
    } else if (value < previousValue) {
      return TrendDirection.down;
    } else {
      return TrendDirection.stable;
    }
  }

  double? _getPreviousValue(double currentValue) {
    // Simple implementation: return a value slightly different
    return currentValue + (_random.nextDouble() - 0.5) * 2.0;
  }
}

