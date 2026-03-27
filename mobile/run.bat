@echo off
setlocal EnableDelayedExpansion
set MODE=%1
set ARG2=%2
set REMOTE_HOST=%3
set DEVICE_SERIAL=

if /I "%MODE%"=="campus" (
  rem Campus mode:
  rem - If USB phone is connected, run on phone with adb reverse.
  rem - Otherwise run normally (emulator/default flutter target).
  echo [MOBILE] Starting campus mode...
  for /f "tokens=1,2" %%A in ('adb devices ^| findstr /R /C:"device$"') do (
    echo %%A | findstr /B /C:"emulator-" >nul
    if errorlevel 1 (
      if not defined DEVICE_SERIAL set DEVICE_SERIAL=%%A
    )
  )

  if defined DEVICE_SERIAL (
    echo [MOBILE] Physical phone detected: !DEVICE_SERIAL!
    echo [MOBILE] Using adb reverse and backend host 127.0.0.1
    adb -s !DEVICE_SERIAL! reverse tcp:8080 tcp:8080
    if errorlevel 1 (
      echo adb reverse failed for device !DEVICE_SERIAL!.
      echo Check USB debugging and connected device authorization.
      exit /b 1
    )
    flutter run -d !DEVICE_SERIAL! --dart-define=APP_ENV=campus --dart-define=API_HOST=127.0.0.1
    goto :eof
  )

  echo [MOBILE] No physical phone detected. Using emulator/default target.
  echo [MOBILE] Backend host will use the platform default - Android emulator = 10.0.2.2
  flutter run --dart-define=APP_ENV=campus
  goto :eof
)

if /I "%MODE%"=="vpn" (
  echo [MOBILE] Starting vpn mode...
  if "!REMOTE_HOST!"=="" set REMOTE_HOST=10.1.10.144

  rem Option: run vpn phone  (off-campus + VPN + USB phone)
  if /I "%ARG2%"=="phone" (
    for /f "tokens=1,2" %%A in ('adb devices ^| findstr /R /C:"device$"') do (
      echo %%A | findstr /B /C:"emulator-" >nul
      if errorlevel 1 (
        if not defined DEVICE_SERIAL set DEVICE_SERIAL=%%A
      )
    )

    if not defined DEVICE_SERIAL (
      echo Could not auto-detect a physical phone.
      echo Use: run vpn phone [REMOTE_HOST]
      echo Example: run vpn phone 10.1.10.144
      exit /b 1
    )

    adb -s !DEVICE_SERIAL! reverse tcp:8080 tcp:8080
    if errorlevel 1 (
      echo adb reverse failed for device !DEVICE_SERIAL!.
      echo Check USB debugging and connected device authorization.
      exit /b 1
    )

    echo [MOBILE] Physical phone detected: !DEVICE_SERIAL!
    echo [MOBILE] Using adb reverse and backend host 127.0.0.1
    echo [MOBILE] Remote host: !REMOTE_HOST!
    flutter run -d !DEVICE_SERIAL! --dart-define=APP_ENV=vpn --dart-define=API_HOST=127.0.0.1 --dart-define=REMOTE_HOST=!REMOTE_HOST!
    goto :eof
  )

  rem Option: run vpn  (off-campus + VPN + emulator/default target)
  echo [MOBILE] No physical phone override selected. Remote host: !REMOTE_HOST!
  flutter run --dart-define=APP_ENV=vpn --dart-define=REMOTE_HOST=!REMOTE_HOST!
  goto :eof
)

if /I "%MODE%"=="local" (
  echo [MOBILE] Starting local mode...
  flutter run --dart-define=APP_ENV=local
  goto :eof
)

:help
echo Usage:
echo   run campus
echo   run vpn
echo   run vpn phone
echo   run local
