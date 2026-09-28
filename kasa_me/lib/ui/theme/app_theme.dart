import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color darkAccent = Color(0xFF111111);
  static const Color lightBackground = Color(0xFFFAF9F6);
  static const Color primaryPurple = Color(0xFF9E8DFF);
  static const Color primaryCyan = Color(0xFF00E5FF);

  // Gradient Colors for Backgrounds
  static const Color gradTop = Color(0xFFF9F7EE);
  static const Color gradMid = Color(0xFFE5F8FA);
  static const Color gradBottom = Color(0xFFDFF6E2);

  static const Color surfaceWhite = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);

  // High-contrast palette
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF1A1A1A);
  static const Color hcTextPrimary = Color(0xFFFFFFFF);
  static const Color hcTextSecondary = Color(0xFFFFCC00);
  static const Color hcAccent = Color(0xFFFFCC00);
  static const Color hcPurple = Color(0xFFBFB3FF);

  static const LinearGradient mainBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
    colors: [gradTop, gradMid, gradBottom],
  );

  static const LinearGradient highContrastGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [hcBackground, hcSurface],
  );

  static LinearGradient backgroundGradient({bool highContrast = false}) =>
      highContrast ? highContrastGradient : mainBackgroundGradient;

  static ThemeData get lightTheme => _buildTheme(highContrast: false);
  static ThemeData get highContrastTheme => _buildTheme(highContrast: true);

  static ThemeData themeFor({bool highContrast = false}) =>
      _buildTheme(highContrast: highContrast);

  static ThemeData _buildTheme({required bool highContrast}) {
    final fg = highContrast ? hcTextPrimary : textPrimary;
    final secondary = highContrast ? hcTextSecondary : textSecondary;
    final primary = highContrast ? hcAccent : primaryPurple;
    final bg = highContrast ? hcBackground : Colors.transparent;

    final baseTextTheme = GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: fg),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: fg),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: fg),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg),
        bodyLarge: TextStyle(fontSize: 16, color: fg),
        bodyMedium: TextStyle(fontSize: 14, color: secondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
      ),
    );

    return ThemeData(
      brightness: highContrast ? Brightness.dark : Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: bg,
      colorScheme: highContrast
          ? ColorScheme.dark(
              primary: hcAccent,
              secondary: hcAccent,
              surface: hcSurface,
              onSurface: hcTextPrimary,
            )
          : const ColorScheme.light(
              primary: primaryPurple,
              secondary: primaryCyan,
              surface: surfaceWhite,
              onSurface: textPrimary,
            ),
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: fg),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: highContrast ? hcAccent : darkAccent,
          foregroundColor: highContrast ? hcBackground : Colors.white,
          minimumSize: const Size(48, 48), // WCAG minimum touch target
          textStyle: GoogleFonts.inter(
            fontSize: highContrast ? 18 : 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: highContrast ? hcSurface : Colors.white.withOpacity(0.6),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: secondary,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: highContrast ? hcAccent : Colors.white, width: 1.5),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: highContrast ? hcAccent : textSecondary),
        ),
        labelStyle: TextStyle(color: secondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
