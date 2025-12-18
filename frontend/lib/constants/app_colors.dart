import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Puerto Rico Palette
  static const Map<int, Color> puertoRico = {
    50: Color(0xFFf1fcf8),
    100: Color(0xFFd1f6eb),
    200: Color(0xFFa3ecd7),
    300: Color(0xFF6ddbc0),
    400: Color(0xFF43c4a8),
    500: Color(0xFF25a78d),
    600: Color(0xFF1b8672),
    700: Color(0xFF1a6b5e),
    800: Color(0xFF19564c),
    900: Color(0xFF194841),
    950: Color(0xFF082b27),
  };

  // Neutral Palette
  static const Map<int, Color> neutral = {
    50: Color(0xFFfafafa),
    100: Color(0xFFededed),
    200: Color(0xFFdfdfdf),
    300: Color(0xFFc8c8c8),
    400: Color(0xFFadadad),
    500: Color(0xFFa1a1a1),
    600: Color(0xFF888888),
    700: Color(0xFF7b7b7b),
    800: Color(0xFF676767),
    900: Color(0xFF545454),
    950: Color(0xFF363636),
  };

  // Primary Colors (Puerto Rico 400 is the new primary)
  static const Color primary = Color(0xFF43c4a8);
  static const Color primaryLight = Color(0xFF6ddbc0); // 300
  static const Color primaryDark = Color(0xFF25a78d); // 500

  // Background Colors - Adjusted to match palette (50)
  static const Color background = Color(0xFFFFFFFF); // Clean white background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFf7f7f7); // Neutral 50
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF363636); // Neutral 950
  static const Color textSecondary = Color(0xFF7b7b7b); // Neutral 700
  static const Color textTertiary = Color(0xFFa1a1a1); // Neutral 500
  static const Color textLight = Color(0xFFadadad); // Neutral 400

  // Border Colors
  static const Color border = Color(0xFFdfdfdf); // Neutral 200
  static const Color borderLight = Color(0xFFededed); // Neutral 100
  static const Color divider = Color(0xFFededed); // Neutral 100
  static const Color grey = Color(0xFFadadad); // Neutral 400

  // Category Colors
  static const Color categoryOrganic = Color(0xFF43c4a8); // Primary
  static const Color categoryInorganic = Color(0xFF2196F3);

  // Status Colors
  static const Color success = Color(0xFF43c4a8); // Primary
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Accent Colors (untuk Tips List Widget)
  static const Color accentBlue = Color(0xFF42A5F5);
  static const Color accentTeal = Color(0xFF26A69A);
  static const Color accentOrange = Color(0xFFFF7043);
  static const Color accentYellow = Color(0xFFFFCA28);

  // Overlay Colors
  static const Color overlay = Color(0x80082b27); // Using 950 with opacity
  static const Color overlayLight = Color(0x40082b27);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFf1fcf8), Color(0xFFFFFFFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF43c4a8), Color(0xFF25a78d)], // 400 -> 500
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
    final lowerCategory = category.toLowerCase();
    switch (lowerCategory) {
      case 'organik':
      case 'organic':
      case 'sampah organik':
        return categoryOrganic;
      case 'anorganik':
      case 'inorganic':
      case 'sampah anorganik':
        return categoryInorganic;
      default:
        return textTertiary;
    }
  }

  // Get category icon by name
  static IconData getCategoryIcon(String category) {
    final lowerCategory = category.toLowerCase();
    switch (lowerCategory) {
      case 'organik':
      case 'organic':
      case 'sampah organik':
        return PhosphorIcons.leaf(PhosphorIconsStyle.regular);
      case 'anorganik':
      case 'inorganic':
      case 'sampah anorganik':
        return PhosphorIcons.recycle(PhosphorIconsStyle.regular);
      default:
        return PhosphorIcons.question(PhosphorIconsStyle.regular);
    }
  }
}
