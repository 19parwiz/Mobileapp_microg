import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/logger.dart';
import '../domain/device.dart';
import '../domain/repositories/i_device_repository.dart';
import 'device_data_source.dart';

class DeviceRepository implements IDeviceRepository {
  final DeviceDataSource _deviceDataSource;
  final FlutterSecureStorage _secureStorage;

  DeviceRepository({
    required DeviceDataSource deviceDataSource,
    required FlutterSecureStorage secureStorage,
  })  : _deviceDataSource = deviceDataSource,
        _secureStorage = secureStorage;

  @override
  Future<List<Device>> getAllDevices() async {
    try {
      final devices = await _deviceDataSource.getAllDevices();
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
      final device = await _deviceDataSource.getDeviceById(id);
      if (device == null) {
        throw Exception('Device not found with id: $id');
      }
      AppLogger.i('Fetched device with id: $id');
      return device;
    } catch (e) {
      AppLogger.e('DeviceRepository.getDeviceById error', e);
      rethrow;
    }
  }

  @override
  Future<Device> getDeviceByDeviceId(String deviceId) async {
    try {
      final device = await _deviceDataSource.getDeviceByDeviceId(deviceId);
      if (device == null) {
        throw Exception('Device not found with deviceId: $deviceId');
      }
      AppLogger.i('Fetched device with deviceId: $deviceId');
      return device;
    } catch (e) {
      AppLogger.e('DeviceRepository.getDeviceByDeviceId error', e);
      rethrow;
    }
  }

  @override
  Future<Device> createDevice(Device device) async {
    try {
      final createdDevice = await _deviceDataSource.addDevice(device);
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
      final updatedDevice = await _deviceDataSource.updateDevice(device);
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
      await _deviceDataSource.deleteDevice(id);
      AppLogger.i('Deleted device with id: $id');
    } catch (e) {
      AppLogger.e('DeviceRepository.deleteDevice error', e);
      rethrow;
    }
  }
}