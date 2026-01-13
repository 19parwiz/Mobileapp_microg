# Android Emulator Troubleshooting Guide

## Issue: "Emulator failed to connect within 5 minutes"

This error occurs when the Android emulator takes too long to boot or fails to start properly.

## Quick Fixes (Try in order)

### 1. **Cold Boot the Emulator**
   - In Android Studio, go to **Device Manager**
   - Find your emulator (Medium Phone API 36.1)
   - Click the **▼ dropdown** next to the device
   - Select **Cold Boot Now**
   - Wait for it to fully boot (can take 2-5 minutes)

### 2. **Delete and Recreate the AVD**
   - In Device Manager, click the **pencil icon** (Edit) or **trash icon** (Delete)
   - Delete the problematic emulator
   - Create a new one:
     - Click **Create Device**
     - Choose a device (e.g., Pixel 5)
     - Select a **lower API level** (recommended: API 33 or 34 instead of 36)
     - Finish the setup

### 3. **Use a Lower API Level**
   - API 36 (Android 16) is very new and may have compatibility issues
   - Recommended: Use **API 33 (Android 13)** or **API 34 (Android 14)**
   - These are more stable and widely tested

### 4. **Check Hardware Acceleration**
   - Open **Android Studio Settings** → **Appearance & Behavior** → **System Settings** → **Android SDK**
   - Go to **SDK Tools** tab
   - Ensure **Android Emulator** and **Intel x86 Emulator Accelerator (HAXM installer)** are installed
   - For AMD processors: Install **Android Emulator Hypervisor Driver for AMD Processors**

### 5. **Increase Emulator Timeout (Android Studio)**
   - Go to **File** → **Settings** → **Build, Execution, Deployment** → **Debugger**
   - Increase **Connection timeout** to 60000 ms (60 seconds) or more

### 6. **Check System Resources**
   - Close other heavy applications
   - Ensure you have at least 8GB RAM available
   - Check if your CPU supports virtualization (required for emulators)

### 7. **Use Command Line to Start Emulator**
   ```bash
   # List available emulators
   flutter emulators
   
   # Launch a specific emulator
   flutter emulators --launch <emulator_id>
   
   # Or use Android SDK emulator directly
   cd %LOCALAPPDATA%\Android\Sdk\emulator
   emulator -avd <avd_name> -no-snapshot-load
   ```

### 8. **Wipe Emulator Data**
   - In Device Manager, click the **▼ dropdown** next to the device
   - Select **Wipe Data**
   - This will reset the emulator to factory settings

### 9. **Check Windows Hyper-V (Windows 10/11)**
   - If you have Hyper-V enabled, it may conflict with Android Emulator
   - You may need to disable Hyper-V or use Windows Hypervisor Platform instead
   - Check: **Control Panel** → **Programs** → **Turn Windows features on or off**

### 10. **Try Running from Terminal**
   ```bash
   cd mobile
   flutter doctor
   flutter devices
   flutter run
   ```

## Recommended Emulator Configuration

For best performance, create an emulator with:
- **Device**: Pixel 5 or Pixel 6
- **API Level**: 33 (Android 13) or 34 (Android 14)
- **Target**: Google APIs (not Google Play)
- **RAM**: 2048 MB or 4096 MB
- **VM Heap**: 512 MB
- **Graphics**: Hardware - GLES 2.0

## Alternative: Use Physical Device

If emulator issues persist:
1. Enable **Developer Options** on your Android phone
2. Enable **USB Debugging**
3. Connect via USB
4. Run `flutter devices` to verify connection
5. Run `flutter run`

## Still Having Issues?

1. Check Flutter doctor: `flutter doctor -v`
2. Update Android SDK and tools
3. Update Flutter: `flutter upgrade`
4. Check Android Studio logs: **Help** → **Show Log in Explorer**

