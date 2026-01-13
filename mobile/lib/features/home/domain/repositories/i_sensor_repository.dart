import '../entities/sensor_dashboard_data.dart';

/// Domain abstraction for retrieving sensor readings (API/mqtt/local, etc).
abstract class ISensorRepository {
  SensorDashboardData getDashboardData({required bool refresh, int hours = 24});
}


