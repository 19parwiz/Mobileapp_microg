import '../domain/device.dart';

/// Data source for devices (mock implementation).
/// In the future, this will be replaced with API calls.
class DeviceDataSource {
  final List<Device> _devices = [];

  /// Initialize with mock data
  DeviceDataSource() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();
    _devices.addAll([
      Device(
        id: 1,
        name: 'Temperature Sensor #1',
        deviceId: 'TEMP-001',
        description: 'Main growing area temperature sensor',
        deviceType: 'Temperature',
        location: 'Growing Room A',
        isActive: true,
        lastSeen: now.subtract(const Duration(minutes: 5)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Device(
        id: 2,
        name: 'Humidity Sensor #1',
        deviceId: 'HUM-001',
        description: 'Monitors humidity levels in growing area',
        deviceType: 'Humidity',
        location: 'Growing Room A',
        isActive: true,
        lastSeen: now.subtract(const Duration(minutes: 3)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Device(
        id: 3,
        name: 'Light Sensor #1',
        deviceId: 'LIGHT-001',
        description: 'Measures light intensity for optimal growth',
        deviceType: 'Light',
        location: 'Growing Room A',
        isActive: true,
        lastSeen: now.subtract(const Duration(minutes: 7)),
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      Device(
        id: 4,
        name: 'Watering System #1',
        deviceId: 'WATER-001',
        description: 'Automated watering system for microgreens',
        deviceType: 'Watering',
        location: 'Growing Room A',
        isActive: false,
        lastSeen: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Device(
        id: 5,
        name: 'CO2 Sensor #1',
        deviceId: 'CO2-001',
        description: 'Monitors CO2 levels for optimal plant growth',
        deviceType: 'CO2',
        location: 'Growing Room B',
        isActive: true,
        lastSeen: now.subtract(const Duration(minutes: 2)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      Device(
        id: 6,
        name: 'Temperature Sensor #2',
        deviceId: 'TEMP-002',
        description: 'Backup temperature sensor',
        deviceType: 'Temperature',
        location: 'Growing Room B',
        isActive: false,
        lastSeen: now.subtract(const Duration(days: 1)),
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);
  }

  /// Get all devices
  Future<List<Device>> getAllDevices() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    return List.from(_devices);
  }

  /// Get device by ID
  Future<Device?> getDeviceById(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _devices.firstWhere((device) => device.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get device by deviceId
  Future<Device?> getDeviceByDeviceId(String deviceId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _devices.firstWhere((device) => device.deviceId == deviceId);
    } catch (e) {
      return null;
    }
  }

  /// Add a new device
  Future<Device> addDevice(Device device) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newDevice = device.copyWith(
      id: _devices.isEmpty ? 1 : _devices.map((d) => d.id ?? 0).reduce((a, b) => a > b ? a : b) + 1,
      createdAt: DateTime.now(),
    );
    _devices.add(newDevice);
    return newDevice;
  }

  /// Update an existing device
  Future<Device> updateDevice(Device device) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _devices.indexWhere((d) => d.id == device.id);
    if (index == -1) {
      throw Exception('Device not found');
    }
    _devices[index] = device;
    return device;
  }

  /// Delete a device
  Future<void> deleteDevice(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _devices.removeWhere((device) => device.id == id);
  }
}
