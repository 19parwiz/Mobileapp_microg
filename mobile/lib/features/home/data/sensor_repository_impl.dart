import '../../../core/utils/logger.dart';
import '../domain/entities/sensor_dashboard_data.dart';
import '../domain/repositories/i_sensor_repository.dart';
import 'sensor_data_service.dart';

/// Mock-data implementation kept around for screens that don't (yet) hit the
/// real sensor service. The dashboard uses [RealSensorRepositoryImpl] instead.
class SensorRepositoryImpl implements ISensorRepository {
  final SensorDataService _service;

  SensorRepositoryImpl({required SensorDataService service}) : _service = service;

  @override
  SensorDashboardData getDashboardData({required bool refresh, int hours = 24}) {
    if (refresh) {
      AppLogger.d('[SENSOR][MOCK] Refreshing dashboard data');
      _service.generateRandomData();
    }

    final data = SensorDashboardData(
      sensorData: _service.getAllSensors(),
      chartData: _service.getHistoricalData(hours: hours),
    );

    AppLogger.d(
      '[SENSOR][MOCK] Returned ${data.sensorData.length} readings, '
      '${data.chartData.length} chart points (window=${hours}h)',
    );
    return data;
  }
}
