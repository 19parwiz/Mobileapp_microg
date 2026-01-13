import 'package:flutter/material.dart';

/// Plant-themed color palette for microgreens management app
class AppColors {
  // Primary Colors - Green (Plant/Leaf Green) - Enhanced for better contrast
  static const Color primary = Color(0xFF2E7D32); // Forest Green
  static const Color primaryDark = Color(0xFF1B5E20); // Dark Green (accent)
  static const Color primaryLight = Color(0xFF66BB6A); // Light Green
  
  // Secondary Colors - Fresh Green
  static const Color secondary = Color(0xFF4CAF50); // Material Green
  static const Color secondaryDark = Color(0xFF388E3C); // Medium Green
  static const Color secondaryLight = Color(0xFF81C784); // Pale Green
  
  // Accent Colors - Earthy tones
  static const Color accent = Color(0xFF8BC34A); // Light Green
  static const Color accentDark = Color(0xFF689F38); // Olive Green
  
  // Background Colors - Enhanced light green background
  static const Color background = Color(0xFFF1F8E9); // Very Light Green Tint
  static const Color backgroundLight = Color(0xFFF9FBE7); // Lighter green tint
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1B3E1F); // Dark Green Background
  
  // Text Colors - Improved contrast
  static const Color textPrimary = Color(0xFF1B5E20); // Dark Green Text (high contrast)
  static const Color textSecondary = Color(0xFF558B2F); // Medium Green Text
  static const Color textHint = Color(0xFF9CCC65); // Light Green Hint
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Gradient Colors for cards
  static const Color gradientStart = Color(0xFFE8F5E9); // Light green gradient start
  static const Color gradientEnd = Color(0xFFFFFFFF); // White gradient end
  static const Color gradientStartDark = Color(0xFF2E7D32); // Dark green gradient start
  static const Color gradientEndDark = Color(0xFF1B5E20); // Darker green gradient end
  
  // Status Colors - Plant Health Colors
  static const Color success = Color(0xFF4CAF50); // Healthy Green
  static const Color error = Color(0xFFD32F2F); // Warning Red (for unhealthy plants)
  static const Color warning = Color(0xFFFBC02D); // Yellow (needs attention)
  static const Color info = Color(0xFF2E7D32); // Info Green
  
  // Plant-specific Colors
  static const Color plantHealthy = Color(0xFF66BB6A); // Healthy plant green
  static const Color plantGrowing = Color(0xFF8BC34A); // Growing plant light green
  static const Color soilColor = Color(0xFF8D6E63); // Brown/Earthy
  
  // Border Colors
  static const Color border = Color(0xFFC8E6C9); // Light Green Border
  static const Color borderFocus = Color(0xFF2E7D32); // Green Focus Border
  
  // Divider
  static const Color divider = Color(0xFFC8E6C9); // Light Green Divider
  
  // Gradient definitions for cards
  static LinearGradient get cardGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
        stops: [0.0, 1.0],
      );
  
  static LinearGradient get cardGradientDark => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStartDark, gradientEndDark],
        stops: [0.0, 1.0],
      );
  
  // Primary gradient for emphasis
  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primaryLight, primary],
        stops: [0.0, 1.0],
      );
}

