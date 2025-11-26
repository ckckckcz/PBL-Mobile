import 'package:flutter/material.dart';

/// App color constants
/// Centralized color management for consistent theming
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryLight = Color(0xFF81C784);
  static const Color primaryDark = Color(0xFF388E3C);

  // Background Colors
  static const Color background = Color(0xFFF5F9F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text Colors
  static const Color textPrimary = Color(0xFF2E3A2F);
  static const Color textSecondary = Color(0xFF607D6B);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF0F0F0);

  // Category Colors
  static const Color categoryOrganic = Color(0xFF4CAF50);
  static const Color categoryInorganic = Color(0xFF2196F3);
  static const Color categoryB3 = Color(0xFFF44336);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Utility method to parse hex color
  static Color fromHex(String hexString) {
    try {
      String hex = hexString.replaceAll('#', '');
      if (hex.length == 6) {
        hex = 'FF$hex';
      }
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return primary; // Default fallback color
    }
  }

  // Get category color by name
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'organik':
      case 'organic':
        return categoryOrganic;
      case 'anorganik':
      case 'inorganic':
        return categoryInorganic;
      case 'b3':
      case 'hazardous':
        return categoryB3;
      default:
        return textTertiary;
    }
  }

  // Get category icon by name
  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'organik':
      case 'organic':
        return Icons.eco;
      case 'anorganik':
      case 'inorganic':
        return Icons.recycling;
      case 'b3':
      case 'hazardous':
        return Icons.warning;
      default:
        return Icons.help_outline;
    }
  }
}
