import 'package:equatable/equatable.dart';

/// Sensor data model for temperature, humidity, and light readings
class SensorData extends Equatable {
  final String sensorType; // 'temperature', 'humidity', 'light'
  final double value;
  final String unit;
  final DateTime timestamp;
  final TrendDirection? trend;

  const SensorData({
    required this.sensorType,
    required this.value,
    required this.unit,
    required this.timestamp,
    this.trend,
  });

  @override
  List<Object?> get props => [sensorType, value, unit, timestamp, trend];

  SensorData copyWith({
    String? sensorType,
    double? value,
    String? unit,
    DateTime? timestamp,
    TrendDirection? trend,
  }) {
    return SensorData(
      sensorType: sensorType ?? this.sensorType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      trend: trend ?? this.trend,
    );
  }
}

/// Trend direction enum
enum TrendDirection {
  up,
  down,
  stable,
}

