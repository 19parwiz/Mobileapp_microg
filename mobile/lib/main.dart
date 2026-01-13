import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/theme/app_theme.dart';
import 'app/theme/theme_provider.dart';
import 'app/router/app_router.dart';
import 'app/di/injector.dart';
import 'core/utils/logger.dart';
import 'features/home/presentation/home_provider.dart';
import 'features/profile/presentation/profile_provider.dart';
import 'features/auth/domain/usecases/get_token_use_case.dart';
import 'features/home/domain/usecases/get_sensor_data_use_case.dart';
import 'features/profile/domain/usecases/get_profile_use_case.dart';
import 'features/profile/domain/usecases/get_settings_use_case.dart';
import 'features/profile/domain/usecases/update_profile_use_case.dart';
import 'features/profile/domain/usecases/update_settings_use_case.dart';
import 'features/device/presentation/device_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup dependency injection
  try {
    await setupDependencyInjection();
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
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            getSensorDataUseCase: getIt<GetSensorDataUseCase>(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            getProfileUseCase: getIt<GetProfileUseCase>(),
            getSettingsUseCase: getIt<GetSettingsUseCase>(),
            updateProfileUseCase: getIt<UpdateProfileUseCase>(),
            updateSettingsUseCase: getIt<UpdateSettingsUseCase>(),
            getTokenUseCase: getIt<GetTokenUseCase>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => getIt<DeviceProvider>(),
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

