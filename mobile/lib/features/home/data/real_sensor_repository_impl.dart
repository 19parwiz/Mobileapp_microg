import '../../../core/utils/logger.dart';
import '../domain/models/sensor_data.dart';
import '../domain/repositories/i_real_sensor_repository.dart';
import 'sensor_api.dart';

/// Real sensor repository implementation using university server API
class RealSensorRepositoryImpl implements IRealSensorRepository {
  final SensorApi _sensorApi;

  RealSensorRepositoryImpl({required SensorApi sensorApi})
      : _sensorApi = sensorApi;

  @override
  Future<SensorData> getSensorData() async {
    try {
      AppLogger.i('Fetching sensor data from university server...');
      final data = await _sensorApi.getSensorData();
      AppLogger.i('Sensor data fetched successfully');
      return data;
    } catch (e) {
      AppLogger.e('RealSensorRepositoryImpl.getSensorData error', e);
      rethrow;
    }
  }
}
