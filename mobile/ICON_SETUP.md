# Microgreens App Icon Setup Guide

## ✅ What Was Done

Your beautiful microgreens app icon has been created and integrated! Here's what happened:

### 1. **Icon Generated**
- **File:** `app_icon.png` (512x512 PNG)
- **Design:** Minimalistic green sprout/microgreens silhouette
- **Colors:** 
  - Dark green (#228B22) - Main leaves
  - Medium sea green (#3CB371) - Stem and accents
  - Light green (#90EE90) - Subtle highlights
  - Soft green background (#F0FAF0)

### 2. **Flutter Launcher Icons Setup**
- Installed `flutter_launcher_icons: ^0.13.1` in dev_dependencies
- Configured for Android and iOS platforms
- Automatically generates all required sizes and formats

### 3. **Icons Generated For:**
- ✅ **Android**: 
  - Default launcher icon (multiple sizes: 48dp, 72dp, 96dp, 144dp, 192dp)
  - Adaptive icon (foreground + background for Android 8.0+)
  - `colors.xml` file created for color definitions
  
- ✅ **iOS**: 
  - App icon (multiple sizes: 120x120, 152x152, 167x167, 180x180)
  - Warning: Alpha channel will be removed for App Store compatibility

### 4. **Icon Locations:**

**Android:**
```
android/app/src/main/res/
├── mipmap-mdpi/ic_launcher.png
├── mipmap-hdpi/ic_launcher.png
├── mipmap-xhdpi/ic_launcher.png
├── mipmap-xxhdpi/ic_launcher.png
├── mipmap-xxxhdpi/ic_launcher.png
└── values/colors.xml
```

**iOS:**
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
└── [various sizes]
```

## 🚀 How to Use

### Build & Test Locally:
```bash
cd mobile
flutter run
```
Your new icon will appear on the home screen!

### Build APK:
```bash
flutter build apk
```

### Build App Bundle (for Play Store):
```bash
flutter build appbundle
```

### Build iOS App:
```bash
flutter build ios
```

## 🔄 If You Want to Update the Icon Later:

1. **Replace the icon:**
   - Create a new `app_icon.png` (512x512 PNG)
   - Place it in `d:\DiplomaMobileAPP\mobile\app_icon.png`

2. **Regenerate icons:**
   ```bash
   cd mobile
   dart run flutter_launcher_icons
   ```

3. **Rebuild the app:**
   ```bash
   flutter run
   # or
   flutter build apk/ios/appbundle
   ```

## 📋 Configuration Reference

Your `pubspec.yaml` configuration:

```yaml
flutter_launcher_icons:
  android: true              # Generate Android icons
  ios: true                  # Generate iOS icons
  image_path: "app_icon.png" # Source image file
  adaptive_icon_background: "#F0FAF0"  # Background for adaptive icons
  adaptive_icon_foreground: "app_icon.png"  # Foreground for adaptive icons
```

## ✨ Icon Specifications

| Platform | Size(s) | Format | Location |
|----------|---------|--------|----------|
| Android | 48, 72, 96, 144, 192 dp | PNG | `android/app/src/main/res/mipmap-*` |
| Android Adaptive | 108 dp | PNG | `android/app/src/main/res/mipmap-*` |
| iOS | 120, 152, 167, 180 px | PNG | `ios/Runner/Assets.xcassets` |

## 🎨 Design Details

**Microgreens Sprout Icon:**
- Central stem with 4 main leaves radiating outward
- One tall central top sprout for visual interest
- Subtle light green accent leaves for depth
- Soil/pot base at the bottom
- Clean, minimalistic aesthetic perfect for the app's professional look

## ⚠️ Important Notes

1. **iOS App Store:** The alpha channel is automatically removed when building for production to meet App Store guidelines
2. **Testing:** After regenerating icons, you may need to do a full rebuild (not just hot reload)
3. **Cache:** If icons don't update visually, try:
   ```bash
   flutter clean
   flutter pub get
   dart run flutter_launcher_icons
   flutter run
   ```

## 📁 Source Files

- **Icon Source:** `app_icon.png` (512x512 PNG)
- **Generator Script:** `generate_icon.py` (Python PIL script)
- **Configuration:** `pubspec.yaml` (flutter_launcher_icons settings)

---

Your app now has a professional, fresh microgreens icon perfect for app stores! 🌱✨
