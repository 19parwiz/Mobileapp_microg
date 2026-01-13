import 'package:flutter/material.dart';

/// App-wide theme controller to switch between light and dark mode.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Set a specific [ThemeMode] (light, dark, or system).
  void setThemeMode(ThemeMode mode) {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
  }

  /// Convenience toggle for a simple on/off dark mode switch.
  /// When [isOn] is true => dark, false => light.
  void toggleDarkMode(bool isOn) {
    setThemeMode(isOn ? ThemeMode.dark : ThemeMode.light);
  }
}

