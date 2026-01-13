import '../../models/device.dart';

abstract class DeviceRepository {
  Future<List<Device>> getDevices();
  Future<Device> createDevice(Device device);
  Future<Device> updateDevice(Device device);
  Future<void> deleteDevice(String id);
  Future<Device?> getDeviceById(String id);
}
