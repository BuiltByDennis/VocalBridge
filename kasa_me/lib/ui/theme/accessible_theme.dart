import 'package:flutter/material.dart';

class AccessibleTheme {
  static const Color primaryTeal = Color(0xFF007A78);
  static const Color secondarySoftBlue = Color(0xFFE8F1F5);
  static const Color accentIndigo = Color(0xFF4A69FF);
  static const Color backgroundSoftGradientStart = Color(0xFFF6F9FC);
  static const Color backgroundSoftGradientEnd = Color(0xFFEDF2F7);
  static const Color cardSurface = Colors.white;

  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryTeal,
        primary: primaryTeal,
        secondary: accentIndigo,
        surface: cardSurface,
        surfaceContainerHighest: secondarySoftBlue,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundSoftGradientStart,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF1A202C), height: 1.2),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A202C), height: 1.25),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2D3748)),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
        bodyLarge: TextStyle(fontSize: 18, color: Color(0xFF4A5568), height: 1.4),
        bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF4A5568), height: 1.4),
        labelLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(64, 64),
          elevation: 2,
          shadowColor: primaryTeal.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        ),
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme;
}
