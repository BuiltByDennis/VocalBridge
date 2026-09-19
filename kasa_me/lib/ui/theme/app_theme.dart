import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color darkAccent = Color(0xFF111111); // Black for heavy text/buttons
  static const Color lightBackground = Color(0xFFFAF9F6); // Soft cream
  static const Color primaryPurple = Color(0xFF9E8DFF); // Soft glowing purple
  static const Color primaryCyan = Color(0xFF00E5FF); // Avatar cyan
  
  // Gradient Colors for Backgrounds
  static const Color gradTop = Color(0xFFF9F7EE); // Pale yellow/cream
  static const Color gradMid = Color(0xFFE5F8FA); // Pale cyan
  static const Color gradBottom = Color(0xFFDFF6E2); // Pale mint green

  static const Color surfaceWhite = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);

  // Modern Linear Gradient background
  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
    colors: [
      gradTop,
      gradMid,
      gradBottom,
    ],
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: Colors.transparent, // We use a container with gradient
      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: primaryCyan,
        surface: surfaceWhite,
        onSurface: textPrimary,
      ),
      fontFamily: 'Inter', // Assuming Inter or system default, we can use default
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAccent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}
