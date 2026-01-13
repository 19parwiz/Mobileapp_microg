import '../domain/entities/sensor_dashboard_data.dart';
import '../domain/repositories/i_sensor_repository.dart';
import 'sensor_data_service.dart';

/// Data-layer implementation backed by the existing mock/random generator.
class SensorRepositoryImpl implements ISensorRepository {
  final SensorDataService _service;

  SensorRepositoryImpl({required SensorDataService service}) : _service = service;

  @override
  SensorDashboardData getDashboardData({required bool refresh, int hours = 24}) {
    if (refresh) {
      _service.generateRandomData();
    }

    return SensorDashboardData(
      sensorData: _service.getAllSensors(),
      chartData: _service.getHistoricalData(hours: hours),
    );
  }
}


