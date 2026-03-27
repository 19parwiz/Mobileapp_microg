# Mobile App Development Progress

> **Last reviewed:** 2026-03-27 — aligned with the current codebase (`lib/`, DI, and routes).  
> For setup and high-level features, see also `README.md`.

---

## Summary

| Area | Status |
|------|--------|
| Core UI, theme, navigation | ✅ Largely complete |
| Auth + JWT (API + secure storage + router guard) | ✅ Complete |
| Home dashboard (live sensor polling) | ✅ Complete |
| Devices (API + screens + CRUD) | ✅ Complete |
| My Plants (API + UI) | ✅ Complete |
| AI assistant **chat** (HTTP to AI service) | ✅ Complete |
| AI **prediction** button / model flow | ✅ Complete (camera capture -> backend -> ai-service) |
| Camera (device + lab stream: HLS / MJPEG / WebView fallbacks) | ✅ Advanced; see “Still to do” for save/preview |
| Responsive layouts (large screens) | ✅ Partial — `ResponsiveConstrained` on key screens |
| MQTT / WebSocket in app | ❌ Not implemented (config stubs + DI TODOs) |
| Profile/settings cloud sync | ⚠️ Local secure storage only |

*Table status verified: 2026-03-26.*

---

## Core Infrastructure

### Theme & design
- ✅ Material 3 theme with primary and secondary colors — 2025-12-13
- ✅ Green plant-themed color palette — 2025-12-13
- ✅ Default text styles configuration — 2025-12-13
- ✅ Light and dark theme support — 2025-12-13
- ✅ Dark mode compatibility for redesigned pages (Auth, Home, Camera, AI, etc.) — 2026-03-19
- ✅ Text contrast and font visibility for light/dark — 2026-03-19

### Routing & navigation
- ✅ GoRouter with login, register, home, profile, settings, camera, AI, devices, admin, etc. — 2026-03-25
- ✅ Error page for invalid routes — 2025-12-13
- ✅ Back button handling with confirmation where applicable — 2025-12-13
- ✅ Bottom navigation (Home, Camera, AI, Profile) with main scaffold — 2025-12-16
- ✅ **Auth redirect:** protected routes require token; logged-in users redirected away from login/register (`app_router.dart`) — 2026-03-25

### Networking & configuration
- ✅ Dio `ApiClient` with timeouts, JSON headers, **Bearer token** interceptor, optional logging — 2026-03-25
- ✅ `ApiConfig`: `baseUrl` for Spring API, `aiServiceUrl`, camera stream hosts (`CAMERA_HOST` / `dart-define` overrides) — 2026-03-25
- ✅ Separate `http.Client` path for university / sensor service where used — 2026-03-25

---

## Core widgets

- ✅ CustomButton (primary/secondary, hover) — 2025-12-13
- ✅ SensorCard — 2025-12-13
- ✅ PlaceholderChart / SensorChart (`fl_chart`) — 2025-12-13
- ✅ ErrorPage — 2025-12-13
- ✅ **ResponsiveConstrained** — max width on tablet/desktop; used on Home, AI, Auth, Profile, Settings, More, My Plants — 2026-03-25

---

## Home dashboard

- ✅ Sensor cards, charts, plant-themed actions, animations — 2025-12-13 / 2025-12-16
- ✅ **Live data:** `HomeProvider` polls **real** sensor data via `GetRealSensorDataUseCase` → `RealSensorRepositoryImpl` → `SensorApi` (not the old mock-only dashboard path) — 2026-03-25
- ✅ ListView for dynamic sensor cards, PopScope migration, logging — 2025-12-13
- ⚠️ Mock sensor stack still registered in DI for `GetSensorDataUseCase` / demos; dashboard uses the **real** path above — 2026-03-25
- ✅ Reduced duplicate sensor console noise by keeping cleaner `[SENSOR]` runtime messages during polling/load flows — 2026-03-26

---

## Authentication

- ✅ Login and registration screens with validation — 2026-03-25
- ✅ `AuthApi` → Spring `/auth/login`, `/auth/register`; JWT stored in **FlutterSecureStorage** — 2026-03-25
- ✅ Logout clears token and user payload (even if API fails) — 2026-03-25
- ✅ `AuthRepository`, use cases, and router integration — 2026-03-25

---

## Camera module

- ✅ Device camera preview and switching (`camera` package) — 2026-03-25
- ✅ Lab / remote streams: HLS, MJPEG viewer, WebView fallback, retry logic (`camera_screen.dart` and widgets) — 2026-03-25
- ✅ `ApiConfig` camera URLs (`cameraHlsBaseUrl`, `cameraMjpegBaseUrl`, overrides) — 2026-03-25
- ✅ Improved HLS startup latency by removing duplicate VideoPlayer probing/initialization — 2026-03-26
- ✅ Stabilized stream behavior by limiting aggressive auto-reconnect loops and adding init timeout — 2026-03-26
- ✅ Reduced confusing extra physical camera entries by limiting visible device cameras to primary front/back — 2026-03-26
- ✅ Improved camera connection test UI: non-2xx HTTP responses (e.g., 404) now show as errors, not success — 2026-03-26
- ✅ Camera capture is connected to AI prediction flow (`Capture & Predict`) with result dialog + latest result card — 2026-03-27
- ✅ Cleaner prediction messages in camera UI (less raw exception text, clearer error wording) — 2026-03-27
- [ ] **Still to do:** persist capture to gallery/files, dedicated preview screen — *(open)*

---

## AI module

- ✅ **Chat:** `AIScreen` + `SendAiChatMessageUseCase` + `AiChatRepositoryImpl` (Dio) with error handling — 2026-03-25
- ✅ **Predictions:** `PredictionRepositoryImpl` now uploads captured image as multipart (`file`) to backend `/api/ai/predict` and parses live model output — 2026-03-27
- ✅ AI screen copy updated to point users to Camera prediction flow (removed outdated “available soon” message) — 2026-03-27
- [ ] **Still to do:** richer prediction history/visualization in AI tab — *(open)*

---

## Charts & data visualization

- ✅ Time-series charts with `fl_chart` — 2025-12-13
- [ ] **Still to do:** deeper interactivity (zoom, scrub, per-metric drill-down) if required for thesis — *(open)*

---

## Backend & IoT integration

- ✅ REST integration for **auth**, **devices**, **plants** (Dio + token) — 2026-03-25
- ✅ **Sensor dashboard:** HTTP polling to configured sensor/university service (`SensorApi` / `ApiConfig.sensorServiceUrl`) — 2026-03-25
- [ ] **Still to do:** **MQTT** client (`app_config.dart` broker TODO; not registered in `injector.dart`) — *(open)*
- [ ] **Still to do:** **WebSocket** client for push updates (`app_config.dart` URL TODO; not registered in `injector.dart`) — *(open)*

---

## Device management

- ✅ Device list, detail, add, edit screens — 2026-03-25
- ✅ `DeviceApi`, `DeviceDataSource`, `DeviceRepository`, use cases, `DeviceProvider` — 2026-03-25
- ✅ Domain model under `features/device/domain/device.dart` (legacy `app/models/device.dart` may still exist — prefer feature module) — 2026-03-25
- [ ] **Still to do:** richer device configuration UI, firmware/OTA, or MQTT-driven control if in scope — *(open)*

---

## My Plants

- ✅ `PlantApi` / `PlantDataSource` / `PlantRepositoryImpl` / use cases / `PlantProvider` / UI (CRUD dialogs, list) — 2026-03-25
- ⚠️ Repository file comment may still say “mock”; **runtime path uses the API** (see `plant_data_source.dart`) — 2026-03-25

---

## Profile, settings, More

- ✅ Profile screen, edit profile, settings (theme, notifications, language, units, auto-refresh, etc.) — 2026-03-25
- ✅ Settings moved to **More** flow (Profile cleaned) — 2026-01-09
- ✅ Local persistence via secure storage (`ProfileRepository`) — 2026-03-25
- [ ] **Still to do:** sync profile/settings with Spring backend if required for grading — *(open)*

---

## Admin

- ✅ Admin panel screen and route (role/usage depends on backend; see backend security) — 2026-03-25

---

## Additional features (not implemented or optional)

- [ ] Push / local **notifications** for alerts — *(open)*
- [ ] **Data export** (CSV, reports) — *(open)*
- [ ] **Forgot password** / reset flow — *(open)*
- [ ] Onboarding / first-run tutorial — *(open)*
- [ ] Pull-to-refresh on home (if desired) — *(open)*
- [ ] Avatar **image upload** to backend — *(open)*
- [ ] **Video playback** polish for recorded streams (deps noted as “ready” in README) — *(open)*

---

## Documentation hygiene

- [ ] Keep this file and `README.md` TODO sections in sync after major changes (several README bullets are outdated vs code) — *(open)*
- ✅ Simplified mobile startup script (`run.bat`) for campus/vpn/local flows with cleaner phone handling — 2026-03-26
- ✅ Simplified mobile console logging:
  - lighter logger output in `core/utils/logger.dart`
  - removed `MainScaffold` tab/build debug spam
  - clearer sensor request / success / error messages — 2026-03-26

---

## Responsive pages

- ✅ **Done (baseline):** `ResponsiveConstrained` applied on main flows (see Core widgets) — 2026-03-25
- [ ] **Optional next steps:** audit remaining screens (Camera full layout, device forms, admin) for the same pattern; consider `LayoutBuilder` breakpoints shared as constants — *(open)*
