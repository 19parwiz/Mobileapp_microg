import '../domain/entities/sensor_dashboard_data.dart';
import '../domain/repositories/i_sensor_repository.dart';
import 'sensor_data_service.dart';

/// Data-layer implementation backed by the existing mock/random generator.
class SensorRepositoryImpl implements ISensorRepository {
  final SensorDataService _service;

  SensorRepositoryImpl({required SensorDataService service}) : _service = service;

  @override
  SensorDashboardData getDashboardData({required bool refresh, int hours = 24}) {
    print('📡 [SensorRepositoryImpl] Getting sensor data (refresh: $refresh)');
    print('   📍 Source: MOCK DATA from SensorDataService (no real sensors connected)');
    
    if (refresh) {
      print('    Refreshing sensor data...');
      _service.generateRandomData();
    }

    final data = SensorDashboardData(
      sensorData: _service.getAllSensors(),
      chartData: _service.getHistoricalData(hours: hours),
    );
    
    print('    Returned ${data.sensorData.length} sensor readings');
    return data;
  }
}


