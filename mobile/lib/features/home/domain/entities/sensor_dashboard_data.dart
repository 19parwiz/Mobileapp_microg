import '../sensor_data.dart';

/// Combined data needed by the home dashboard.
class SensorDashboardData {
  final List<SensorData> sensorData;
  final List<SensorData> chartData;

  const SensorDashboardData({
    required this.sensorData,
    required this.chartData,
  });
}


