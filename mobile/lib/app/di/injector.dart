import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';
import '../network/api_client.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/get_token_use_case.dart';
import '../../features/auth/domain/usecases/get_current_user_use_case.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/logout_use_case.dart';
import '../../features/auth/domain/usecases/register_use_case.dart';
import '../../features/home/data/sensor_data_service.dart';
import '../../features/home/data/sensor_repository_impl.dart';
import '../../features/home/domain/repositories/i_sensor_repository.dart';
import '../../features/home/domain/usecases/get_sensor_data_use_case.dart';
import '../../features/home/data/sensor_api.dart';
import '../../features/home/data/real_sensor_repository_impl.dart';
import '../../features/home/domain/repositories/i_real_sensor_repository.dart';
import '../../features/home/domain/usecases/get_real_sensor_data_use_case.dart';
import '../../features/profile/domain/repositories/i_profile_repository.dart';
import '../../features/profile/domain/usecases/clear_profile_use_case.dart';
import '../../features/profile/domain/usecases/get_profile_use_case.dart';
import '../../features/profile/domain/usecases/get_settings_use_case.dart';
import '../../features/profile/domain/usecases/update_profile_use_case.dart';
import '../../features/profile/domain/usecases/update_settings_use_case.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/ai/data/prediction_repository_impl.dart';
import '../../features/ai/data/ai_chat_repository_impl.dart';
import '../../features/ai/domain/entities/ai_chat_message.dart';
import '../../features/ai/domain/repositories/i_ai_chat_repository.dart';
import '../../features/ai/domain/repositories/i_prediction_repository.dart';
import '../../features/ai/domain/usecases/generate_prediction_use_case.dart';
import '../../features/ai/domain/usecases/send_ai_chat_message_use_case.dart';
import '../../features/device/data/device_api.dart';
import '../../features/device/data/device_data_source.dart';
import '../../features/device/data/device_repository.dart';
import '../../features/device/domain/repositories/i_device_repository.dart';
import '../../features/device/domain/usecases/device_use_cases.dart';
import '../../features/device/presentation/device_provider.dart';
import '../../features/home/presentation/home_provider.dart';
import '../../features/my_plants/data/plant_api.dart';
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

  // Dio API Client
  final apiClient = ApiClient(secureStorage: getIt<FlutterSecureStorage>());
  getIt.registerSingleton<ApiClient>(apiClient);
  getIt.registerSingleton<Dio>(apiClient.dio);

  // Data Sources
  getIt.registerLazySingleton<AuthApi>(
    () => AuthApi(
      dio: getIt<Dio>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );

  // Device API - uses Dio with automatic token injection
  getIt.registerLazySingleton<DeviceApi>(
    () => DeviceApi(dio: getIt<Dio>()),
  );

  // Device Data Source - uses real API
  getIt.registerLazySingleton<DeviceDataSource>(
    () => DeviceDataSource(deviceApi: getIt<DeviceApi>()),
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

  // Real sensor API (university server)
  getIt.registerLazySingleton<SensorApi>(
    () => SensorApi(httpClient: getIt<http.Client>()),
  );

  // Real sensor repository (university server with polling)
  getIt.registerLazySingleton<IRealSensorRepository>(
    () => RealSensorRepositoryImpl(sensorApi: getIt<SensorApi>()),
  );

  getIt.registerLazySingleton<IPredictionRepository>(
    () => PredictionRepositoryImpl(),
  );

  getIt.registerLazySingleton<IAiChatRepository>(
    () => AiChatRepositoryImpl(dio: getIt<Dio>()),
  );

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
  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(authRepository: getIt<IAuthRepository>()),
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

  // Real sensor use case (university server with live polling)
  getIt.registerLazySingleton<GetRealSensorDataUseCase>(
    () => GetRealSensorDataUseCase(repository: getIt<IRealSensorRepository>()),
  );

  // Home provider (dashboard) depends on REAL sensor use case with polling
  getIt.registerLazySingleton<HomeProvider>(
    () => HomeProvider(getRealSensorDataUseCase: getIt<GetRealSensorDataUseCase>()),
  );

  getIt.registerLazySingleton<GeneratePredictionUseCase>(
    () => GeneratePredictionUseCase(
      predictionRepository: getIt<IPredictionRepository>(),
    ),
  );

  getIt.registerLazySingleton<SendAiChatMessageUseCase>(
    () => SendAiChatMessageUseCase(
      repository: getIt<IAiChatRepository>(),
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

  // My Plants feature - Data, repository, use cases and provider (now with real API)
  getIt.registerLazySingleton<PlantApi>(
    () => PlantApi(dio: getIt<Dio>()),
  );
  
  getIt.registerLazySingleton<PlantDataSource>(
    () => PlantDataSource(plantApi: getIt<PlantApi>()),
  );
  
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

