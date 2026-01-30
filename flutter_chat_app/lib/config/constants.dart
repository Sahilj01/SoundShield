import 'package:flutter/material.dart';

/// App-wide color scheme matching the React Native design
class AppColors {
  // Modern Primary Colors
  static const Color primary = Color(0xFF6366f1); // Indigo 500
  static const Color primaryDark = Color(0xFF4f46e5); // Indigo 600
  static const Color primaryLight = Color(0xFF818cf8); // Indigo 400

  // Modern Accents
  static const Color accent = Color(0xFF8b5cf6); // Purple 500
  static const Color accentDark = Color(0xFF7c3aed); // Purple 600

  // Background Colors
  static const Color background = Color(0xFFf8fafc); // Slate 50
  static const Color backgroundSecondary = Colors.white;
  static const Color backgroundDark = Color(0xFF0f172a); // Slate 900

  // Text Colors
  static const Color text = Color(0xFF1e293b); // Slate 800
  static const Color textSecondary = Color(0xFF64748b); // Slate 500
  static const Color textLight = Color(0xFF94a3b8); // Slate 400
  static const Color textInverse = Colors.white;

  // Message Bubbles
  static const Color messageSent = Color(0xFF6366f1); // Indigo 500
  static const Color messageReceived = Color(0xFFf1f5f9); // Slate 100

  // Borders & Dividers
  static const Color border = Color(0xFFe2e8f0); // Slate 200
  static const Color borderLight = Color(0xFFf1f5f9); // Slate 100
  static const Color divider = Color(0xFFcbd5e1); // Slate 300

  // Status Colors
  static const Color success = Color(0xFF10b981); // Emerald 500
  static const Color error = Color(0xFFef4444); // Red 500
  static const Color warning = Color(0xFFf59e0b); // Amber 500
  static const Color info = Color(0xFF3b82f6); // Blue 500

  // Legacy (for compatibility)
  static const Color red = Color(0xFFef4444);
  static const Color pink = Color(0xFFec4899);
  static const Color teal = Color(0xFF14b8a6);
  static const Color grey = Color(0xFF94a3b8);
}

/// App theme configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.backgroundSecondary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundSecondary,
        foregroundColor: AppColors.text,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textInverse,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.backgroundSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primaryLight,
        secondary: AppColors.accent,
        surface: AppColors.backgroundDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textInverse,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
}
