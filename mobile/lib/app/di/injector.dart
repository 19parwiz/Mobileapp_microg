import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/logger.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/get_token_use_case.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/usecases/register_use_case.dart';
import '../../features/home/data/sensor_data_service.dart';
import '../../features/home/data/sensor_repository_impl.dart';
import '../../features/home/domain/repositories/i_sensor_repository.dart';
import '../../features/home/domain/usecases/get_sensor_data_use_case.dart';
import '../../features/profile/domain/repositories/i_profile_repository.dart';
import '../../features/profile/domain/usecases/clear_profile_use_case.dart';
import '../../features/profile/domain/usecases/get_profile_use_case.dart';
import '../../features/profile/domain/usecases/get_settings_use_case.dart';
import '../../features/profile/domain/usecases/update_profile_use_case.dart';
import '../../features/profile/domain/usecases/update_settings_use_case.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/ai/data/prediction_repository_impl.dart';
import '../../features/ai/domain/repositories/i_prediction_repository.dart';
import '../../features/ai/domain/usecases/generate_prediction_use_case.dart';
import '../../features/device/data/device_data_source.dart';
import '../../features/device/data/device_repository.dart';
import '../../features/device/domain/repositories/i_device_repository.dart';
import '../../features/device/domain/usecases/device_use_cases.dart';
import '../../features/device/presentation/device_provider.dart';
import '../../features/home/presentation/home_provider.dart';
import '../../features/my_plants/data/plant_data_source.dart';
import '../../features/my_plants/data/plant_repository_impl.dart';
import '../../features/my_plants/domain/repositories/i_plant_repository.dart';
import '../../features/my_plants/domain/usecases/get_plants_use_case.dart';
import '../../features/my_plants/domain/usecases/add_plant_use_case.dart';
import '../../features/my_plants/domain/usecases/update_plant_use_case.dart';
import '../../features/my_plants/domain/usecases/delete_plant_use_case.dart';
import '../../features/my_plants/presentation/providers/PlantProvider.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Secure Storage
  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  // HTTP Client
  final httpClient = http.Client();
  getIt.registerSingleton<http.Client>(httpClient);

  // Data Sources
  getIt.registerLazySingleton<AuthApi>(
    () => AuthApi(
      httpClient: getIt<http.Client>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(
      authApi: getIt<AuthApi>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<IProfileRepository>(
    () => ProfileRepository(
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  getIt.registerLazySingleton<SensorDataService>(() => SensorDataService());
  getIt.registerLazySingleton<ISensorRepository>(
    () => SensorRepositoryImpl(service: getIt<SensorDataService>()),
  );

  getIt.registerLazySingleton<IPredictionRepository>(
    () => PredictionRepositoryImpl(),
  );

  // Device dependencies (using mock data for now, will replace with API later)
  getIt.registerLazySingleton<DeviceDataSource>(() => DeviceDataSource());

  getIt.registerLazySingleton<IDeviceRepository>(
    () => DeviceRepository(
      deviceDataSource: getIt<DeviceDataSource>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  // Device repository is already registered above as IDeviceRepository
  // No need for duplicate registration

  // Use cases (presentation depends ONLY on these)
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(authRepository: getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(authRepository: getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(authRepository: getIt<IAuthRepository>()),
  );
  getIt.registerLazySingleton<GetTokenUseCase>(
    () => GetTokenUseCase(authRepository: getIt<IAuthRepository>()),
  );

  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(profileRepository: getIt<IProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(profileRepository: getIt<IProfileRepository>()),
  );
  getIt.registerLazySingleton<GetSettingsUseCase>(
    () => GetSettingsUseCase(profileRepository: getIt<IProfileRepository>()),
  );
  getIt.registerLazySingleton<UpdateSettingsUseCase>(
    () => UpdateSettingsUseCase(profileRepository: getIt<IProfileRepository>()),
  );
  getIt.registerLazySingleton<ClearProfileUseCase>(
    () => ClearProfileUseCase(profileRepository: getIt<IProfileRepository>()),
  );

  getIt.registerLazySingleton<GetSensorDataUseCase>(
    () => GetSensorDataUseCase(sensorRepository: getIt<ISensorRepository>()),
  );

  // Home provider (dashboard) depends on sensor use case
  getIt.registerLazySingleton<HomeProvider>(
    () => HomeProvider(getSensorDataUseCase: getIt<GetSensorDataUseCase>()),
  );

  getIt.registerLazySingleton<GeneratePredictionUseCase>(
    () => GeneratePredictionUseCase(
      predictionRepository: getIt<IPredictionRepository>(),
    ),
  );

  // Device use cases
  getIt.registerLazySingleton<GetAllDevicesUseCase>(
    () => GetAllDevicesUseCase(repository: getIt<IDeviceRepository>()),
  );
  getIt.registerLazySingleton<GetDeviceByIdUseCase>(
    () => GetDeviceByIdUseCase(repository: getIt<IDeviceRepository>()),
  );
  getIt.registerLazySingleton<CreateDeviceUseCase>(
    () => CreateDeviceUseCase(repository: getIt<IDeviceRepository>()),
  );
  getIt.registerLazySingleton<UpdateDeviceUseCase>(
    () => UpdateDeviceUseCase(repository: getIt<IDeviceRepository>()),
  );
  getIt.registerLazySingleton<DeleteDeviceUseCase>(
    () => DeleteDeviceUseCase(repository: getIt<IDeviceRepository>()),
  );

  // Device provider
  getIt.registerLazySingleton<DeviceProvider>(
    () => DeviceProvider(
      getAllDevicesUseCase: getIt<GetAllDevicesUseCase>(),
      getDeviceByIdUseCase: getIt<GetDeviceByIdUseCase>(),
      createDeviceUseCase: getIt<CreateDeviceUseCase>(),
      updateDeviceUseCase: getIt<UpdateDeviceUseCase>(),
      deleteDeviceUseCase: getIt<DeleteDeviceUseCase>(),
    ),
  );

  // My Plants feature - Data, repository, use cases and provider (mock/local)
  getIt.registerLazySingleton<PlantDataSource>(() => PlantDataSource());
  getIt.registerLazySingleton<IPlantRepository>(
    () => PlantRepositoryImpl(dataSource: getIt<PlantDataSource>()),
  );

  getIt.registerLazySingleton<GetPlantsUseCase>(
    () => GetPlantsUseCase(repository: getIt<IPlantRepository>()),
  );
  getIt.registerLazySingleton<AddPlantUseCase>(
    () => AddPlantUseCase(repository: getIt<IPlantRepository>()),
  );
  getIt.registerLazySingleton<UpdatePlantUseCase>(
    () => UpdatePlantUseCase(repository: getIt<IPlantRepository>()),
  );
  getIt.registerLazySingleton<DeletePlantUseCase>(
    () => DeletePlantUseCase(repository: getIt<IPlantRepository>()),
  );

  getIt.registerLazySingleton<PlantProvider>(
    () => PlantProvider(
      getPlantsUseCase: getIt<GetPlantsUseCase>(),
      addPlantUseCase: getIt<AddPlantUseCase>(),
      updatePlantUseCase: getIt<UpdatePlantUseCase>(),
      deletePlantUseCase: getIt<DeletePlantUseCase>(),
    ),
  );

  // TODO: Register MQTT client when implementing IoT features
  // TODO: Register WebSocket client when implementing real-time features
  // TODO: Register camera controller when implementing camera features
  // TODO: Register video player when implementing video features

  AppLogger.i('Dependency injection setup completed');
}

