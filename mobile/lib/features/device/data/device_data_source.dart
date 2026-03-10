import '../domain/device.dart';
import 'device_api.dart';

/// Data source for devices.
/// Uses the DeviceApi to fetch and manage devices from the backend.
class DeviceDataSource {
  final DeviceApi _deviceApi;

  DeviceDataSource({required DeviceApi deviceApi}) : _deviceApi = deviceApi;

  /// Get all devices from backend
  Future<List<Device>> getAllDevices() async {
    return await _deviceApi.getAllDevices();
  }

  /// Get device by ID from backend
  Future<Device?> getDeviceById(int id) async {
    try {
      return await _deviceApi.getDeviceById(id);
    } catch (e) {
      return null;
    }
  }

  /// Get device by deviceId from backend
  Future<Device?> getDeviceByDeviceId(String deviceId) async {
    try {
      return await _deviceApi.getDeviceByDeviceId(deviceId);
    } catch (e) {
      return null;
    }
  }

  /// Create a new device via backend API
  Future<Device> addDevice(Device device) async {
    return await _deviceApi.createDevice(device);
  }

  /// Update an existing device via backend API
  Future<Device> updateDevice(Device device) async {
    if (device.id == null) {
      throw Exception('Device ID is required for update');
    }
    return await _deviceApi.updateDevice(device.id!, device);
  }

  /// Delete a device via backend API
  Future<void> deleteDevice(int id) async {
    return await _deviceApi.deleteDevice(id);
  }
}
