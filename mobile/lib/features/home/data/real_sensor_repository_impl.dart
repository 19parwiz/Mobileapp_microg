import '../../../core/utils/logger.dart';
import '../domain/models/sensor_data.dart';
import '../domain/repositories/i_real_sensor_repository.dart';
import 'sensor_api.dart';

/// Thin pass-through to [SensorApi] so the domain layer stays decoupled
/// from `package:http`.
class RealSensorRepositoryImpl implements IRealSensorRepository {
  final SensorApi _sensorApi;

  RealSensorRepositoryImpl({required SensorApi sensorApi})
      : _sensorApi = sensorApi;

  @override
  Future<SensorData> getSensorData() async {
    try {
      return await _sensorApi.getSensorData();
    } catch (e) {
      // SensorApi already logs the root cause; this line tells us where
      // the error bubbled up so the trail in the console stays readable.
      AppLogger.e('[SENSOR] Repository fetch failed', e);
      rethrow;
    }
  }
}
