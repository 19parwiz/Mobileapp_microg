import 'package:equatable/equatable.dart';

/// Legacy sensor model used by mock/random dashboard flow.
class SensorData extends Equatable {
  final String sensorType;
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
}

enum TrendDirection { up, down, stable }
