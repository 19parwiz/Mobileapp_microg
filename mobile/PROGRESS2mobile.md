# Mobile App Snapshot (Design Phase)
_Last updated: 2026-01-05_

## 0. Architecture refactor (Clean Architecture) — as of 2026-01-05

- ✅ **Presentation layer isolated**:
  - ✅ UI code stays in `presentation/` (screens/providers).
  - ✅ Presentation depends on **use cases only** (no direct `data/*` imports).
- ✅ **Domain use cases (1 action = 1 class)**:
  - ✅ `LoginUseCase`, `RegisterUseCase`, `LogoutUseCase`, `GetTokenUseCase`
  - ✅ `GetSensorDataUseCase`
  - ✅ `GetProfileUseCase`, `UpdateProfileUseCase`, `GetSettingsUseCase`, `UpdateSettingsUseCase`, `ClearProfileUseCase`
  - ✅ `GeneratePredictionUseCase` (still placeholder behavior, but now routed through domain)
- ✅ **Repository abstractions in domain**:
  - ✅ `IAuthRepository`, `IProfileRepository`, `ISensorRepository`, `IPredictionRepository`
- ✅ **Data layer implements repositories**:
  - ✅ Auth/profile repos handle API + secure storage as before.
  - ✅ Home dashboard uses `SensorRepositoryImpl` (wraps existing mock `SensorDataService`).
  - ✅ AI uses a minimal `PredictionRepositoryImpl` placeholder.
- ✅ **Dependency injection updated**:
  - ✅ `app/di/injector.dart` registers repository interfaces + use cases.
  - ✅ Providers are constructed with use cases in `main.dart`.

## 1. What the app already has (visible in UI) — as of 2025-12-16

### Home (Dashboard)
- ✅ **Welcome section**: "Microgreens Management Dashboard" card with plant icon and green gradient.
- ✅ **Sensor readings**:
  - ✅ Temperature, Humidity (and Light in code) shown as separate cards.
  - ✅ Each card shows value, unit, and an "optimal range" helper line.
  - ✅ Trend arrows (up/down/flat) indicate direction of change.
  - ✅ Cards use plant-themed gradients, icons, and improved contrast.
- ✅ **Sensor data chart**:
  - ✅ "Sensor Readings Over Time" card with time‑series chart (fl_chart).
  - ✅ Styled axes, grid, and legend for Temperature / Humidity / Light.
- ✅ **Animations**:
  - ✅ Sensor cards fade+slide in on load (staggered).
  - ✅ Chart appears with scale+fade animation.
  - ✅ Welcome card has fade+scale animation.
  - ✅ Trend arrows animate on data updates.
  - ✅ Buttons have subtle press/scale effect with visual feedback.
- ✅ **Navigation**:
  - ✅ AppBar with plant icon and title.
  - ✅ Profile icon in AppBar (navigates to Profile screen).

### Camera screen
- ✅ **Live camera preview**:
  - ✅ Lists all available cameras on device (front/back/external).
  - ✅ Automatically initializes first camera on screen open.
  - ✅ Live `CameraPreview` with proper aspect ratio.
  - ✅ Fade-in animation on preview load.
- ✅ **Camera switching**:
  - ✅ Scrollable list of available cameras with lens direction labels.
  - ✅ Tap any camera to switch preview (safely disposes old controller).
  - ✅ Selected camera highlighted with checkmark icon.
  - ✅ Subtle scale animation on camera list items.
- ✅ **Capture button**:
  - ✅ Plant-themed gradient button with shadow effects.
  - ✅ Placeholder action (shows snackbar "Capture feature coming soon!").
  - ✅ Ready for future AI/ML integration.
- ✅ **Navigation & safety**:
  - ✅ Close button in AppBar that safely disposes camera controller.
  - ✅ Proper cleanup on screen close.

### AI Predictions screen
- ✅ **Screen layout**:
  - ✅ AppBar with plant icon and "AI Predictions" title.
  - ✅ Large leaf icon in center.
  - ✅ Heading "AI Predictions" with subtext about AI‑powered growth predictions.
- ✅ **Action button**:
  - ✅ Primary green "Generate Predictions" button.
  - ✅ Uses `GeneratePredictionUseCase` and shows snackbar "AI predictions feature coming soon!" (still placeholder).

### Profile screen
- ✅ **User information display**:
  - ✅ Dynamic user name and email from `ProfileProvider`.
  - ✅ Avatar placeholder (ready for image upload).
  - ✅ Data loaded from local storage on screen open.
- ✅ **Edit Profile screen**:
  - ✅ Editable name and phone number fields.
  - ✅ Email field (read-only, from auth).
  - ✅ Input validation (name required, phone format).
  - ✅ Save button with gradient styling.
  - ✅ Changes persisted to local secure storage.
- ✅ **Settings screen**:
  - ✅ **Theme toggle**: Switch between light/dark mode (persisted).
  - ✅ **Notifications**: Enable/disable all, email, and push notifications.
  - ✅ **Language selection**: English, Farsi, Kazakh, Russian (with checkmarks).
  - ✅ **Temperature unit**: Toggle between Celsius/Fahrenheit.
  - ✅ **Auto-refresh**: Toggle for automatic data updates.
  - ✅ All settings persisted to local secure storage.
- ✅ **Actions**:
  - ✅ "Edit Profile" navigates to edit screen.
  - ✅ "Settings" navigates to settings screen.
  - ✅ Full‑width red "Sign Out" button wired via domain use cases (`LogoutUseCase` + `ClearProfileUseCase`).

### Global navigation & theme
- ✅ **Bottom navigation bar**:
  - ✅ Tabs: Home, Camera, AI, Profile.
  - ✅ Uses `MainScaffold` with `IndexedStack` → **state is preserved** between tabs.
  - ✅ Subtle icon scale animation on active tab.
- ✅ **Theming & UI polish**:
  - ✅ Material 3 light/dark themes with dynamic theme switching.
  - ✅ Plant‑themed green palette (primary, secondary, accent, backgrounds).
  - ✅ **Rounded corners**: All cards and buttons use `radiusXL` (24px) for modern look.
  - ✅ **Gradient buttons**: Key action buttons use plant-themed gradients with shadows.
  - ✅ **Improved spacing**: Enhanced padding and margins throughout for better readability.
  - ✅ **Text hierarchy**: Bold titles (20-24px), smaller subtitles (13-14px), proper letter spacing.
  - ✅ **Touch targets**: All buttons meet minimum 48x48dp touch area requirements.
  - ✅ **Visual feedback**: InkWell splash effects, scale animations, and hover states.
  - ✅ Gradient backgrounds for key cards (Welcome, SensorCard, SensorChart).
  - ✅ Consistent typography and spacing using `AppSizes`.

## 2. What exists only as placeholders (design ready, logic missing) — as of 2025-12-16

### Camera module
- ✅ **Already done**:
  - ✅ Live camera preview with camera listing and switching.
  - ✅ Camera initialization and controller management.
  - ✅ Capture button with gradient styling (placeholder action).
- ⏳ **Still needed (future work)**:
  - ⏳ Actual image capture functionality (save photo to device).
  - ⏳ Image preview after capture.
  - ⏳ Pass captured image into AI module (when implemented).
  - ⏳ Optional: Video recording support.

### AI module
- ✅ **Already done**:
  - ✅ AI Predictions screen UI and navigation.
  - ✅ "Generate Predictions" button with placeholder snackbar.
- ⏳ **Still needed**:
  - ⏳ Connect to real AI model (local or backend API).
  - ⏳ Show prediction results (health status, recommendations, confidence).
  - ⏳ Optional: charts / history of predictions.

### Profile & settings
- ✅ **Already done**:
  - ✅ Complete profile management with editable name, email, phone.
  - ✅ Full settings screen with theme toggle, notifications, language, temperature unit, auto-refresh.
  - ✅ All data persisted to local secure storage (`FlutterSecureStorage`).
  - ✅ Sign out logic connected via domain use cases (`LogoutUseCase` + `ClearProfileUseCase`).
- ⏳ **Still needed**:
  - ⏳ Avatar image upload/change functionality.
  - ⏳ Backend sync for profile and settings (currently local-only).
  - ⏳ Profile picture cropping/editing tools.

## 3. Data & backend status — as of 2025-12-16

- ✅ **Home dashboard data**:
  - ✅ Uses mock sensor data + generated chart data.
  - ✅ Sensor cards and chart are dynamic (they respond to provider updates).
  - ✅ **Loading states**: Skeleton placeholders for sensor cards during data fetch.
  - ✅ **Empty states**: Friendly message with refresh button when no data available.
  - ✅ **Error states**: Error message with retry button on data fetch failures.
- ⏳ **Backend integration (not yet implemented)**:
  - ⏳ No real API / MQTT / WebSocket wired up yet.
  - ⏳ Ideal next step: define sensor data API contract and connect HomeDashboard to live data.

## 4. UX & visual polish status — as of 2025-12-17

- ✅ **Strong/finished for design phase**:
  - ✅ Overall navigation structure (bottom nav + GoRouter).
  - ✅ Consistent plant‑themed branding and gradients.
  - ✅ Dashboard cards + chart layout and animations.
  - ✅ Button interactions and visual hierarchy.
  - ✅ **Empty/error states** implemented with friendly messages and retry buttons.
  - ✅ **Loading skeletons** for sensor cards during data fetch.
  - ✅ **Accessibility**: All buttons meet 48x48dp minimum touch targets.
  - ✅ **Rounded corners** throughout (24px radius) for modern look.
  - ✅ **Gradient buttons** on key actions with shadow effects.
  - ✅ **Improved text hierarchy** with proper font sizes and weights.
  - ✅ **Enhanced spacing** for better readability.

- ⏳ **Good candidates for next improvements**:
  - ⏳ **Accessibility**: Screen reader labels, contrast ratio verification.
  - ⏳ **Haptic feedback** on button presses.
  - ⏳ **Pull-to-refresh** gesture on home screen.
  - ⏳ **Swipe gestures** for navigation between tabs.

## 5. Recent improvements & bug fixes — as of 2025-12-16

- ✅ **Bug fixes**:
  - ✅ Fixed "index out of bounds" error in bottom navigation bar.
  - ✅ Fixed build errors (missing closing parentheses in animation widgets).
  - ✅ Fixed language selection dialog display issues in Settings screen.

- ✅ **UI enhancements**:
  - ✅ All cards and buttons now use rounded corners (`radiusXL` = 24px).
  - ✅ Key buttons feature plant-themed gradients with shadow effects.
  - ✅ Improved spacing and padding throughout the app.
  - ✅ Enhanced text hierarchy (bold titles, smaller subtitles).
  - ✅ Fade-in and scale animations on cards and buttons.
  - ✅ Better touch targets and visual feedback on all interactive elements.

## 6. Suggestions for what to add next (decision helper) — as of 2025-12-16

If you want to stay in **pure UI/design mode**:
- ⏳ Add **detailed sensor screens** (tap a card → "Temperature details" with history chart and recommendations).
- ⏳ Add **onboarding / walkthrough** for first‑time users (3–4 lightweight intro pages).
- ⏳ Add **pull-to-refresh** gesture on home screen.
- ⏳ Add **haptic feedback** on button presses for better UX.

If you want to move toward **functionality / data**:
- ⏳ Implement **real sensor data API integration** and replace mocks.
- ⏳ Implement **actual image capture** (save photo to device/gallery).
- ⏳ Add **image preview screen** after capture with edit/share options.
- ⏳ Define **AI prediction response model** and build a result UI (cards, badges, maybe a small chart).

If you want to focus on **user account features**:
- ⏳ Wire **auth navigation flow** (login/register routes → gated home, etc).
- ⏳ Add **avatar image upload** functionality (camera/gallery picker).
- ⏳ Implement **backend sync** for profile and settings (currently local-only).
- ⏳ Add **profile picture cropping/editing** tools.

---
Use this file as a high‑level map: it shows what is visually complete, what is placeholder‑only, and which areas are best candidates for your **next milestone** (UI polish vs. real data vs. auth/AI features).

**Recent milestone achievements (2025-12-16)**:
- ✅ Complete UI polish with rounded corners, gradients, and animations
- ✅ Full camera preview implementation with camera switching
- ✅ Complete profile and settings management with local persistence
- ✅ Empty/error states and loading skeletons for better UX
- ✅ All critical bugs fixed and app building successfully




- Note: 1 bug found!!! when cliking and returning