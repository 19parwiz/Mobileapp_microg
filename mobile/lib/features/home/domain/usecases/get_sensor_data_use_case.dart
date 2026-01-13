import '../entities/sensor_dashboard_data.dart';
import '../repositories/i_sensor_repository.dart';

/// One action: get sensor dashboard data (optionally refreshed).
class GetSensorDataUseCase {
  final ISensorRepository _sensorRepository;

  GetSensorDataUseCase({required ISensorRepository sensorRepository})
      : _sensorRepository = sensorRepository;

  SensorDashboardData call({required bool refresh, int hours = 24}) {
    return _sensorRepository.getDashboardData(refresh: refresh, hours: hours);
  }
}


