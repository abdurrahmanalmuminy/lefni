import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary color
  static const Color primaryColor = Color(0xFF1D1F56);

  // Light theme colors
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightSurfaceColor = Color(0xFFF0F0F0); // Slightly darker for navigation bars
  static const Color lightTextColor = Color(0xFF1A1A1A);
  static const Color lightSecondaryTextColor = Color(0xFF666666);

  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1A1A1A); // Slightly darker for navigation bars
  static const Color darkTextColor = Color(0xFFFFFFFF);
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0);

  // Get Rubik text theme
  static TextTheme _getRubikTextTheme(ColorScheme colorScheme) {
    return GoogleFonts.rubikTextTheme().copyWith(
      displayLarge: GoogleFonts.rubik(color: colorScheme.onSurface),
      displayMedium: GoogleFonts.rubik(color: colorScheme.onSurface),
      displaySmall: GoogleFonts.rubik(color: colorScheme.onSurface),
      headlineLarge: GoogleFonts.rubik(color: colorScheme.onSurface),
      headlineMedium: GoogleFonts.rubik(color: colorScheme.onSurface),
      headlineSmall: GoogleFonts.rubik(color: colorScheme.onSurface),
      titleLarge: GoogleFonts.rubik(color: colorScheme.onSurface),
      titleMedium: GoogleFonts.rubik(color: colorScheme.onSurface),
      titleSmall: GoogleFonts.rubik(color: colorScheme.onSurface),
      bodyLarge: GoogleFonts.rubik(color: colorScheme.onSurface),
      bodyMedium: GoogleFonts.rubik(color: colorScheme.onSurface),
      bodySmall: GoogleFonts.rubik(color: colorScheme.onSurface),
      labelLarge: GoogleFonts.rubik(color: colorScheme.onSurface),
      labelMedium: GoogleFonts.rubik(color: colorScheme.onSurface),
      labelSmall: GoogleFonts.rubik(color: colorScheme.onSurface),
    );
  }

  // Light theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryColor,
      secondary: primaryColor.withValues(alpha: 0.8),
      surface: lightSurfaceColor,
      error: const Color(0xFFB00020),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextColor,
      onError: Colors.white,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackgroundColor, // Lighter than surface for body
      textTheme: _getRubikTextTheme(colorScheme),
      fontFamily: GoogleFonts.rubik().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackgroundColor, // Match body background
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.rubik(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: primaryColor,
      secondary: primaryColor.withValues(alpha: 0.8),
      surface: darkSurfaceColor,
      error: const Color(0xFFCF6679),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextColor,
      onError: Colors.white,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackgroundColor, // Lighter than surface for body
      textTheme: _getRubikTextTheme(colorScheme),
      fontFamily: GoogleFonts.rubik().fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackgroundColor, // Match body background
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.rubik(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.rubik(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}

