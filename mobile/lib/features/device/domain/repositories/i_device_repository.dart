import '../domain/device.dart';

abstract class IDeviceRepository {
  Future<List<Device>> getAllDevices();
  Future<Device> getDeviceById(int id);
  Future<Device> getDeviceByDeviceId(String deviceId);
  Future<Device> createDevice(Device device);
  Future<Device> updateDevice(int id, Device device);
  Future<void> deleteDevice(int id);
}