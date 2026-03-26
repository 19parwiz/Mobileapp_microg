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
      return await _sensorApi.getSensorData();
    } catch (e) {
      AppLogger.e('[SENSOR] Repository fetch failed', e);
      rethrow;
    }
  }
}
