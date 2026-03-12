# Microgreens Management - Flutter Mobile App

A production-grade Flutter mobile application for managing microgreens with IoT integration, AI predictions, and real-time monitoring.

## 🏗️ Architecture

This app follows **Clean Architecture** principles with a feature-based folder structure:

```
lib/
├── main.dart                 # App entry point
├── app/                      # App-level configuration
│   ├── di/                   # Dependency injection setup
│   ├── router/               # Navigation configuration
│   ├── config/               # App configuration
│   └── theme/                # App theming
├── core/                     # Shared utilities and widgets
│   ├── utils/                # Utility functions (validators, logger)
│   ├── constants/            # App constants (strings, colors, sizes)
│   └── widgets/              # Reusable widgets
└── features/                 # Feature modules
    ├── auth/                 # Authentication feature
    │   ├── data/             # Data layer (API, repository)
    │   ├── domain/           # Domain layer (models)
    │   └── presentation/     # UI layer (screens)
    ├── home/                 # Home feature
    └── profile/              # Profile feature
```

## 🚀 Features

### Core Architecture
- ✅ **Clean Architecture** - Separation of concerns with data, domain, and presentation layers
- ✅ **Dependency Injection** - Using GetIt for service locator pattern
- ✅ **Routing** - GoRouter for declarative navigation
- ✅ **State Management** - Provider for reactive state management
- ✅ **HTTP Client** - HTTP package for REST API communication
- ✅ **Secure Storage** - FlutterSecureStorage for sensitive data persistence
- ✅ **Material 3** - Modern Material Design 3 theming with light/dark mode support
- ✅ **Reusable Widgets** - Custom buttons, inputs, cards, and loading indicators
- ✅ **Form Validation** - Comprehensive validators for user inputs
- ✅ **Error Handling** - Robust error handling with user-friendly messages

### Implemented Features
- ✅ **Home Dashboard** - Real-time sensor data visualization with animated cards and charts
- ✅ **Camera Screen** - Live camera preview with camera switching and capture button
- ✅ **Profile Management** - Editable user profile with local persistence
- ✅ **Settings Screen** - Theme toggle, notifications, language selection, and preferences
- ✅ **UI Polish** - Rounded corners, gradient buttons, smooth animations, and modern design
- ✅ **Loading States** - Skeleton placeholders for better UX during data fetch
- ✅ **Empty/Error States** - Friendly messages with retry functionality

## 📦 Dependencies

### Core Dependencies
- `provider` - State management
- `get_it` - Dependency injection
- `go_router` - Navigation
- `http` - HTTP client
- `flutter_secure_storage` - Secure storage
- `camera` - Camera functionality (✅ implemented)
- `fl_chart` - Data visualization (✅ implemented)
- `equatable` - Value equality
- `mqtt_client` - MQTT for IoT communication (ready for implementation)
- `web_socket_channel` - WebSocket for real-time updates (ready for implementation)
- `chewie` & `video_player` - Video playback (ready for implementation)

## 🛠️ Setup

1. **Install Flutter** (if not already installed)
   ```bash
   flutter --version
   ```

2. **Get dependencies**
   ```bash
   cd mobile
   flutter pub get
   ```

3. **Choose backend host (emulator or real phone)**
    - Default behavior:
       - Android emulator uses `10.0.2.2`
       - iOS simulator, web, desktop use `localhost`
    - For a real phone on the same Wi-Fi, pass your computer LAN IP:
       - `flutter run --dart-define=API_HOST=192.168.1.20 --dart-define=AI_HOST=192.168.1.20`
    - If sensor/AI runs on another machine, set `AI_HOST` to that IP.
    - Make sure phone and backend are in the same network and backend port is reachable.

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Usage

### Home Dashboard
- View real-time sensor readings (Temperature, Humidity, Light)
- Interactive charts with time-series data visualization
- Animated sensor cards with trend indicators
- Loading skeletons and error states with retry functionality

### Camera Screen
- Live camera preview with automatic initialization
- Switch between available cameras (front/back/external)
- Capture button ready for AI/ML integration
- Safe camera controller disposal

### Profile & Settings
- **Edit Profile**: Update name, email, and phone number with validation
- **Settings**:
  - Toggle between light/dark theme (persisted)
  - Configure notifications (all, email, push)
  - Select language (English, Farsi, Kazakh, Russian)
  - Set temperature unit (Celsius/Fahrenheit)
  - Enable/disable auto-refresh
- All settings persisted to local secure storage

### Navigation
- Bottom navigation bar with 4 tabs (Home, Camera, AI, Profile)
- State preservation between tabs using IndexedStack
- Declarative routing with GoRouter
- Deep linking support
- Error handling for invalid routes

### Authentication
- Login screen with email and password validation
- Registration screen with password confirmation
- JWT token-based authentication with secure storage

### Dependency Injection
All dependencies are registered in `lib/app/di/injector.dart`. To add new dependencies:

```dart
getIt.registerLazySingleton<YourService>(() => YourService());
```

### Adding New Features
1. Create a new folder under `lib/features/`
2. Follow the structure: `data/`, `domain/`, `presentation/`
3. Register dependencies in `injector.dart`
4. Add routes in `app_router.dart`

## 🔌 Backend Integration

The app is configured to connect to the Spring Boot backend. Ensure:

1. Backend is running on the configured port
2. CORS is enabled for your mobile app origin
3. API endpoints match the expected structure

## 📝 TODO Items

### High Priority
- [ ] Implement actual image capture (save photo to device/gallery)
- [ ] Add image preview screen after capture
- [ ] Connect to real sensor data API (replace mock data)
- [ ] Implement AI prediction model integration
- [ ] Add avatar image upload functionality

### Medium Priority
- [ ] Implement MQTT client for IoT device communication
- [ ] Implement WebSocket client for real-time updates
- [ ] Add device management screens
- [ ] Add detailed sensor screens (tap card for history)
- [ ] Implement backend sync for profile and settings
- [ ] Add pull-to-refresh gesture on home screen
- [ ] Add haptic feedback on button presses

### Low Priority
- [ ] Add video playback for recorded content
- [ ] Implement forgot password functionality
- [ ] Add device CRUD operations
- [ ] Add onboarding/walkthrough for first-time users
- [ ] Add swipe gestures for navigation between tabs

## 🎨 Customization

### Colors
Edit `lib/core/constants/app_colors.dart` to customize the plant-themed green color scheme. The app uses a consistent palette with primary, secondary, accent colors, and gradients.

### Theme
Modify `lib/app/theme/app_theme.dart` to adjust the app's visual appearance. The app supports:
- Material 3 design system
- Light and dark themes with dynamic switching
- Rounded corners (24px radius) throughout
- Gradient buttons with shadow effects
- Custom text hierarchy and spacing

### Strings
Update `lib/core/constants/app_strings.dart` for localization-ready string management. Currently supports English, Farsi, Kazakh, and Russian.

### Sizes & Spacing
Edit `lib/core/constants/app_sizes.dart` to adjust padding, margins, border radius, and other sizing constants used throughout the app.

## 🧪 Testing

Run tests with:
```bash
flutter test
```

## 📄 License

This project is part of a diploma mobile application.

## 🐛 Known Issues & Recent Fixes

### Fixed Issues (2025-12-16)
- ✅ Fixed "index out of bounds" error in bottom navigation bar
- ✅ Fixed build errors (missing closing parentheses in animation widgets)
- ✅ Fixed language selection dialog display issues in Settings screen

### Current Status
- ✅ App builds successfully
- ✅ All critical bugs resolved
- ✅ UI polish complete with rounded corners, gradients, and animations
- ✅ Camera preview fully functional
- ✅ Profile and settings with local persistence working

---

**Note**: Remember to update the API base URL in `app_config.dart` before running the app. For development, the app uses mock sensor data and local storage for profile/settings.

