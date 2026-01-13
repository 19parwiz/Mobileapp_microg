import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/utils/logger.dart';
import '../domain/device.dart';
import '../domain/repositories/i_device_repository.dart';
import 'device_api.dart';

class DeviceRepository implements IDeviceRepository {
  final DeviceApi _deviceApi;
  final FlutterSecureStorage _secureStorage;

  DeviceRepository({
    required DeviceApi deviceApi,
    required FlutterSecureStorage secureStorage,
  })  : _deviceApi = deviceApi,
        _secureStorage = secureStorage;

  @override
  Future<List<Device>> getAllDevices() async {
    try {
      final devices = await _deviceApi.getAllDevices();
      AppLogger.i('Fetched ${devices.length} devices');
      return devices;
    } catch (e) {
      AppLogger.e('DeviceRepository.getAllDevices error', e);
      rethrow;
    }
  }

  @override
  Future<Device> getDeviceById(int id) async {
    try {
      final device = await _deviceApi.getDeviceById(id);
      AppLogger.i('Fetched device with id: $id');
      return device;
    } catch (e) {
      AppLogger.e('DeviceRepository.getDeviceById error', e);
      rethrow;
    }
  }

  @override
  Future<Device> getDeviceByDeviceId(String deviceId) async {
    // This would need a backend endpoint, for now throw not implemented
    throw UnimplementedError('getDeviceByDeviceId not implemented');
  }

  @override
  Future<Device> createDevice(Device device) async {
    try {
      final createdDevice = await _deviceApi.createDevice(device);
      AppLogger.i('Created device: ${createdDevice.name}');
      return createdDevice;
    } catch (e) {
      AppLogger.e('DeviceRepository.createDevice error', e);
      rethrow;
    }
  }

  @override
  Future<Device> updateDevice(int id, Device device) async {
    try {
      final updatedDevice = await _deviceApi.updateDevice(id, device);
      AppLogger.i('Updated device with id: $id');
      return updatedDevice;
    } catch (e) {
      AppLogger.e('DeviceRepository.updateDevice error', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteDevice(int id) async {
    try {
      await _deviceApi.deleteDevice(id);
      AppLogger.i('Deleted device with id: $id');
    } catch (e) {
      AppLogger.e('DeviceRepository.deleteDevice error', e);
      rethrow;
    }
  }
}