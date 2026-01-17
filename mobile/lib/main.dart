import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/theme/app_theme.dart';
import 'app/theme/theme_provider.dart';
import 'app/router/app_router.dart';
import 'app/di/injector.dart';
import 'core/utils/logger.dart';

// Providers
import 'features/profile/presentation/profile_provider.dart';
import 'features/device/presentation/device_provider.dart';
import 'features/home/presentation/home_provider.dart';
import 'features/my_plants/presentation/providers/PlantProvider.dart';

// PlantProvider uses MockGetPlants internally

// Plant use cases
import 'features/my_plants/domain/usecases/get_plants_use_case.dart';
import 'features/my_plants/domain/usecases/add_plant_use_case.dart';
import 'features/my_plants/domain/usecases/update_plant_use_case.dart';
import 'features/my_plants/domain/usecases/delete_plant_use_case.dart';
import 'features/my_plants/data/plant_repository_impl.dart';
import 'features/my_plants/data/plant_data_source.dart';

// Auth & profile use cases
import 'features/profile/domain/usecases/get_profile_use_case.dart';
import 'features/profile/domain/usecases/get_settings_use_case.dart';
import 'features/profile/domain/usecases/update_profile_use_case.dart';
import 'features/profile/domain/usecases/update_settings_use_case.dart';
import 'features/auth/domain/usecases/get_token_use_case.dart';

// Home / sensors (commented for now)
// import 'features/home/presentation/home_provider.dart';
// import 'features/home/domain/usecases/get_sensor_data_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await setupDependencyInjection(); // DI setup
    AppLogger.i('App initialized successfully');
  } catch (e) {
    AppLogger.e('Failed to initialize app', e);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [

        /// 🌱 PLANTS PROVIDER (from DI)
        ChangeNotifierProvider<PlantProvider>(
          create: (_) => getIt<PlantProvider>(),
        ),

        /// 🎨 THEME PROVIDER
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),

        /// 👤 PROFILE PROVIDER
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(
            getProfileUseCase: getIt<GetProfileUseCase>(),
            getSettingsUseCase: getIt<GetSettingsUseCase>(),
            updateProfileUseCase: getIt<UpdateProfileUseCase>(),
            updateSettingsUseCase: getIt<UpdateSettingsUseCase>(),
            getTokenUseCase: getIt<GetTokenUseCase>(),
          ),
        ),

        /// 📱 DEVICE PROVIDER
        ChangeNotifierProvider<DeviceProvider>(
          create: (_) => getIt<DeviceProvider>(),
        ),

        /// ⚙️ SENSORS (registered via DI)
        ChangeNotifierProvider<HomeProvider>(
          create: (_) => getIt<HomeProvider>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'Microgreens Management',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
