import 'package:flutter/material.dart';
import '../../../core/utils/logger.dart';
import '../domain/device.dart';
import '../domain/usecases/device_use_cases.dart';

class DeviceProvider with ChangeNotifier {
  final GetAllDevicesUseCase _getAllDevicesUseCase;
  final GetDeviceByIdUseCase _getDeviceByIdUseCase;
  final CreateDeviceUseCase _createDeviceUseCase;
  final UpdateDeviceUseCase _updateDeviceUseCase;
  final DeleteDeviceUseCase _deleteDeviceUseCase;

  DeviceProvider({
    required GetAllDevicesUseCase getAllDevicesUseCase,
    required GetDeviceByIdUseCase getDeviceByIdUseCase,
    required CreateDeviceUseCase createDeviceUseCase,
    required UpdateDeviceUseCase updateDeviceUseCase,
    required DeleteDeviceUseCase deleteDeviceUseCase,
  })  : _getAllDevicesUseCase = getAllDevicesUseCase,
        _getDeviceByIdUseCase = getDeviceByIdUseCase,
        _createDeviceUseCase = createDeviceUseCase,
        _updateDeviceUseCase = updateDeviceUseCase,
        _deleteDeviceUseCase = deleteDeviceUseCase;

  List<Device> _devices = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDevices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _devices = await _getAllDevicesUseCase();
      AppLogger.i('Loaded ${_devices.length} devices');
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('DeviceProvider.loadDevices error', e);
      
      // Fallback to demo data if backend is unavailable
      if (errorMsg.contains('Failed host lookup') || 
          errorMsg.contains('Connection refused') ||
          errorMsg.contains('SocketException')) {
        AppLogger.i('Backend unavailable. Loading demo devices.');
        _devices = _getDemoDevices();
        _errorMessage = 'Backend unavailable - showing demo data';
      } else {
        _errorMessage = errorMsg;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Demo devices for offline testing
  List<Device> _getDemoDevices() {
    return [
      Device(
        id: 1,
        name: 'Greenhouse Sensor #1',
        deviceType: 'sensor',
        location: 'Greenhouse A',
        description: 'Temperature and humidity monitoring device',
        isActive: true,
        deviceId: 'DEV-00001',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Device(
        id: 2,
        name: 'Light Controller #1',
        deviceType: 'controller',
        location: 'Greenhouse A',
        description: 'Automated LED grow light controller',
        isActive: true,
        deviceId: 'DEV-00002',
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
        lastSeen: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Device(
        id: 3,
        name: 'Camera Feed #1',
        deviceType: 'camera',
        location: 'Greenhouse B',
        description: 'Real-time monitoring camera',
        isActive: false,
        deviceId: 'DEV-00003',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        lastSeen: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  Future<Device?> getDeviceById(int id) async {
    try {
      return await _getDeviceByIdUseCase(id);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('DeviceProvider.getDeviceById error', e);
      return null;
    }
  }

  Future<bool> createDevice(Device device) async {
    try {
      final createdDevice = await _createDeviceUseCase(device);
      _devices.add(createdDevice);
      notifyListeners();
      AppLogger.i('Device created successfully');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('DeviceProvider.createDevice error', e);
      return false;
    }
  }

  Future<bool> updateDevice(int id, Device device) async {
    try {
      final updatedDevice = await _updateDeviceUseCase(id, device);
      final index = _devices.indexWhere((d) => d.id == id);
      if (index != -1) {
        _devices[index] = updatedDevice;
        notifyListeners();
      }
      AppLogger.i('Device updated successfully');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('DeviceProvider.updateDevice error', e);
      return false;
    }
  }

  Future<bool> deleteDevice(int id) async {
    try {
      await _deleteDeviceUseCase(id);
      _devices.removeWhere((d) => d.id == id);
      notifyListeners();
      AppLogger.i('Device deleted successfully');
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      AppLogger.e('DeviceProvider.deleteDevice error', e);
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}