import 'package:flutter/material.dart';

/// KitchenOS Theme Configuration
///
/// Optimized for "Combat Mode" - high contrast, distance readability,
/// and knuckle-tap friendly UI elements
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Neon accent colors for high visibility through steam
  static const Color neonGreen = Color(0xFF00FF41);
  static const Color neonBlue = Color(0xFF00D9FF);
  static const Color neonOrange = Color(0xFFFF6B00);
  static const Color neonRed = Color(0xFFFF0055);
  static const Color neonYellow = Color(0xFFFFED00);

  // Background colors for deep contrast
  static const Color darkBackground = Color(0xFF0A0E27);
  static const Color surfaceDark = Color(0xFF1A1F3A);
  static const Color surfaceDarker = Color(0xFF0F1529);

  /// Combat Mode Theme - Maximum visibility and tap targets
  static ThemeData get combatModeTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonBlue,
        tertiary: neonOrange,
        error: neonRed,
        surface: surfaceDark,
        background: darkBackground,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),

      // Typography - Optimized for distance reading
      textTheme: const TextTheme(
        // Huge text for critical info (timers, next step)
        displayLarge: TextStyle(
          fontSize: 96,
          fontWeight: FontWeight.bold,
          letterSpacing: -1.5,
          color: neonGreen,
          fontFamily: 'RobotoMono',
          shadows: [
            Shadow(
              color: neonGreen,
              blurRadius: 20,
            ),
          ],
        ),
        // Large headings
        displayMedium: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: Colors.white,
          fontFamily: 'RobotoMono',
        ),
        // Task names
        headlineLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontFamily: 'RobotoMono',
        ),
        // Subtitles
        titleLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: neonBlue,
          fontFamily: 'RobotoMono',
        ),
        // Body text (must be large)
        bodyLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.normal,
          color: Colors.white70,
          fontFamily: 'RobotoMono',
        ),
        // Small labels
        labelLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white60,
          fontFamily: 'RobotoMono',
          letterSpacing: 1.2,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: surfaceDarker,
        elevation: 8,
        shadowColor: neonGreen.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: neonGreen,
            width: 2,
          ),
        ),
      ),

      // Elevated Button Theme - Knuckle-tap size
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(120, 80), // Large tap targets
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          backgroundColor: neonGreen,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'RobotoMono',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(80, 80),
          padding: const EdgeInsets.all(20),
          iconSize: 48,
          foregroundColor: neonGreen,
        ),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceDarker,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: neonGreen,
          fontFamily: 'RobotoMono',
        ),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: neonGreen,
        thickness: 2,
        space: 32,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: neonGreen,
        linearTrackColor: surfaceDark,
        circularTrackColor: surfaceDark,
      ),
    );
  }

  /// Standard Theme - For non-combat UI (settings, editing)
  static ThemeData get standardTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: neonGreen,
        brightness: Brightness.dark,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'RobotoMono'),
        bodyMedium: TextStyle(fontFamily: 'RobotoMono'),
        bodySmall: TextStyle(fontFamily: 'RobotoMono'),
      ),
    );
  }

  /// Critical alert color (for "Remove from oven NOW" type alerts)
  static Color get criticalAlert => neonRed;

  /// Warning color (for "Start soon" notifications)
  static Color get warningAlert => neonYellow;

  /// Success color (for completed tasks)
  static Color get successColor => neonGreen;

  /// Active task color
  static Color get activeColor => neonBlue;
}

/// Combat Mode specific dimensions
class CombatDimensions {
  CombatDimensions._();

  // Minimum tap target size for knuckle/wet hands
  static const double minTapTarget = 80.0;

  // Padding and spacing for readability
  static const double spacingXLarge = 48.0;
  static const double spacingLarge = 32.0;
  static const double spacingMedium = 24.0;
  static const double spacingSmall = 16.0;

  // Timer display size
  static const double timerDisplaySize = 120.0;

  // Card sizing
  static const double cardMinHeight = 200.0;
}
