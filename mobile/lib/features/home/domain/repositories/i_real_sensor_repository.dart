import '../models/sensor_data.dart';

/// Repository interface for real sensor data from university server
abstract class IRealSensorRepository {
  /// Fetch live sensor data from university server
  /// Includes current readings and historical data (last 10 points)
  Future<SensorData> getSensorData();
}
