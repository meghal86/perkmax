import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryGreen = Color(0xFF004D40);
  static const Color accentGold = Color(0xFFD4AF37);

  // Backgrounds
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(
    0xFF030213,
  ); // From --sidebar-primary
  static const Color white = Colors.white;
  static const Color textDark = Color(0xFF2C3E50); // From --foreground

  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFD4183D); // From --destructive

  // Gradients
  static final List<Color> goldGradient = [
    const Color(0xFFD4AF37),
    const Color(0xFFFFD700),
  ];

  static final List<Color> greenGradient = [
    const Color(0xFF004D40),
    const Color(0xFF00695C),
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      primaryColor: primaryGreen,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: accentGold,
        surface: white,
        error: error,
        onPrimary: white,
        onSecondary: white,
        onSurface: textDark,
        onError: white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: GoogleFonts.playfairDisplay(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            color: textDark,
            fontWeight: FontWeight.bold,
          ),
          headlineLarge: GoogleFonts.playfairDisplay(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
          headlineMedium: GoogleFonts.playfairDisplay(
            color: textDark,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
          titleLarge: GoogleFonts.inter(
            color: textDark,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          bodyLarge: GoogleFonts.inter(color: textDark, fontSize: 16),
          bodyMedium: GoogleFonts.inter(
            color: textDark.withValues(alpha: 0.8),
            fontSize: 14,
          ),
          labelLarge: GoogleFonts.inter(
            color: white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.black26,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        showUnselectedLabels: true,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: white,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  // Adapted for Light Mode
  static BoxDecoration get glassDecoration {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // Restored Gradients
  static final List<Color> cardGradients = [
    const Color(0xFF004D40), // Primary Green
    const Color(0xFFD4AF37), // Primary Gold
    const Color(0xFF2C3E50), // Dark Blue/Gray
    const Color(0xFF5D4037), // Brown
    const Color(0xFF455A64), // Blue Gray
    const Color(0xFFC62828), // Dark Red
    const Color(0xFF1565C0), // Dark Blue
    const Color(0xFF2E7D32), // Forest Green
  ];

  // Legacy aliases to prevent breakages during refactor
  // Ideally should be replaced in screens
  static const Color cardBackground = Colors.white;
  static const Color accentBlue = Color(0xFF1565C0);
  static const Color accentPurple = Color(0xFF6A1B9A);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color errorRed = Color(0xFFC62828);
  static const Color primaryGold = accentGold;
  static const Color surfaceColor = Color(0xFFF5F5F5);

  static LinearGradient get backgroundGradient {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [lightBackground, Color(0xFFECEFF1)],
    );
  }
}
