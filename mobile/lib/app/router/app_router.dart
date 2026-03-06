import 'package:go_router/go_router.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/camera/presentation/camera_screen.dart';
import '../../features/ai/presentation/ai_screen.dart';
import '../../features/device/presentation/device_list_screen.dart';
import '../../features/device/presentation/add_device_screen.dart';
import '../../features/device/presentation/edit_device_screen.dart';
import '../../features/device/presentation/device_detail_screen.dart';
import '../../features/admin/presentation/admin_panel_screen.dart';
import '../../core/widgets/main_scaffold.dart';
import '../../core/widgets/error_page.dart';
import '../../core/utils/logger.dart';
import '../di/injector.dart';
import '../../features/auth/domain/usecases/get_token_use_case.dart';

/// GoRouter configuration with /home and /profile routes
/// Includes error handling for invalid routes
class AppRouter {
  // Route paths
  static const String home = '/home';      
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';
  static const String camera = '/camera';
  static const String ai = '/ai';
  static const String devices = '/devices';
  static const String addDevice = '/devices/add';
  static const String editDevice = '/devices/edit';
  static const String deviceDetail = '/devices/detail';
  static const String admin = '/admin';

  // Route names for navigation
  static const String homeName = 'home';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String profileName = 'profile';
  static const String editProfileName = 'editProfile';
  static const String settingsName = 'settings';
  static const String cameraName = 'camera';
  static const String aiName = 'ai';
  static const String devicesName = 'devices';
  static const String addDeviceName = 'addDevice';
  static const String editDeviceName = 'editDevice';
  static const String deviceDetailName = 'deviceDetail';
  static const String adminName = 'admin';

  // List of routes that require authentication
  static const List<String> _protectedRoutes = [
    home,
    profile,
    editProfile,
    settings,
    camera,
    ai,
    devices,
    addDevice,
    editDevice,
    deviceDetail,
    admin,
  ];

  // List of public (unprotected) routes
  static const List<String> _publicRoutes = [
    login,
    register,
  ];

  // GoRouter instance with defined router
  /// GoRouter instance with routes and error handling
  static final GoRouter router = GoRouter(
    initialLocation: login,
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      try {
        // Get the current token from secure storage
        final token = await getIt<GetTokenUseCase>()();
        final isLoggedIn = token != null && token.isNotEmpty;
        final currentPath = state.matchedLocation;

        // Check if current route is a public route
        final isOnPublicRoute = _publicRoutes.contains(currentPath) ||
            currentPath.startsWith(login) ||
            currentPath.startsWith(register);

        // SECURITY: If user is NOT logged in
        if (!isLoggedIn) {
          // Allow access to public routes (login, register)
          if (isOnPublicRoute) {
            return null; // Stay on the route
          }
          // Redirect any attempt to access protected routes to login
          return login;
        }

        // SECURITY: If user IS logged in
        if (isLoggedIn) {
          // Don't allow logged-in users to go back to login/register
          if (isOnPublicRoute) {
            return home; // Redirect to home instead
          }
          // Allow access to protected routes
          return null; // Stay on the route
        }

        return null;
      } catch (e) {
        // If there's any error checking token, redirect to login as safeguard
        AppLogger.e('Router redirect error', e);
        return login;
      }
    },
    routes: [  
      GoRoute(
        path: login,
        name: loginName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: registerName,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: home,
        name: homeName,
        builder: (context, state) => const MainScaffold(),
      ),
      GoRoute(
        path: profile,
        name: profileName,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: editProfile,
        name: editProfileName,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: settings,
        name: settingsName,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: camera,
        name: cameraName,
        builder: (context, state) => const CameraScreen(showAppBar: true),
      ),
      GoRoute(
        path: ai,
        name: aiName,
        builder: (context, state) => const AIScreen(showAppBar: true),
      ),
      GoRoute(
        path: devices,
        name: devicesName,
        builder: (context, state) => const DeviceListScreen(),
      ),
      GoRoute(
        path: addDevice,
        name: addDeviceName,
        builder: (context, state) => const AddDeviceScreen(),
      ),
      GoRoute(
        path: '$editDevice/:id',
        name: editDeviceName,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditDeviceScreen(deviceId: id);
        },
      ),
      GoRoute(
        path: '$deviceDetail/:id',
        name: deviceDetailName,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DeviceDetailScreen(deviceId: id);
        },
      ),
      GoRoute(
        path: admin,
        name: adminName,
        builder: (context, state) => const AdminPanelScreen(),
      ),
    ],
    errorBuilder: (context, state) {
      // Extract error information
      final error = state.error;
      final errorMessage = error?.toString();
      final routePath = state.uri.toString();

      return ErrorPage(
        errorMessage: errorMessage,
        routePath: routePath,
      );
    },
  );
}


