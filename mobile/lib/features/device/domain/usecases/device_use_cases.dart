import '../device.dart';
import '../repositories/i_device_repository.dart';

class GetAllDevicesUseCase {
  final IDeviceRepository _repository;

  GetAllDevicesUseCase({required IDeviceRepository repository})
      : _repository = repository;

  Future<List<Device>> call() => _repository.getAllDevices();
}

class GetDeviceByIdUseCase {
  final IDeviceRepository _repository;

  GetDeviceByIdUseCase({required IDeviceRepository repository})
      : _repository = repository;

  Future<Device> call(int id) => _repository.getDeviceById(id);
}

class CreateDeviceUseCase {
  final IDeviceRepository _repository;

  CreateDeviceUseCase({required IDeviceRepository repository})
      : _repository = repository;

  Future<Device> call(Device device) => _repository.createDevice(device);
}

class UpdateDeviceUseCase {
  final IDeviceRepository _repository;

  UpdateDeviceUseCase({required IDeviceRepository repository})
      : _repository = repository;

  Future<Device> call(int id, Device device) =>
      _repository.updateDevice(id, device);
}

class DeleteDeviceUseCase {
  final IDeviceRepository _repository;

  DeleteDeviceUseCase({required IDeviceRepository repository})
      : _repository = repository;

  Future<void> call(int id) => _repository.deleteDevice(id);
}