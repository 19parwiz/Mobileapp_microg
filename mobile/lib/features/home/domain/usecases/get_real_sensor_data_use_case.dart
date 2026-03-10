import '../models/sensor_data.dart';
import '../repositories/i_real_sensor_repository.dart';

/// Fetch real sensor data from university server
/// Returns live readings with historical data for charting
class GetRealSensorDataUseCase {
  final IRealSensorRepository _repository;

  GetRealSensorDataUseCase({required IRealSensorRepository repository})
      : _repository = repository;

  Future<SensorData> call() => _repository.getSensorData();
}
