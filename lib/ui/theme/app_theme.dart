import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color bgColor = Color(0xFFF8FAFC); // Apple Silver-Grey Background
  static const Color cardColor = Color(0xFFFFFFFF); // Pure White Surface
  static const Color primaryColor = Color(0xFF6366F1); // Indigo Accent
  static const Color secondaryColor = Color(0xFF8B5CF6); // Purple Accent
  static const Color accentColor = Color(0xFF10B981); // Success Green
  static const Color darkSurfaceColor = Color(0xFF0F172A); // Dark Steel Editor

  // Typography / Text Colors
  static const Color primaryTextColor = Color(0xFF0F172A); // Slate 900
  static const Color secondaryTextColor = Color(0xFF475569); // Slate 600

  // UI Element Colors for Light Theme
  static const Color dividerColor = Color(0x0F000000); // 6% opacity black
  static const Color borderLightColor = Color(0x08000000); // 3% opacity black
  static const Color borderMediumColor = Color(0x0F000000); // 6% opacity black

  // SWOT & Contextual Colors
  static const Color strengthColor = Color(0xFF10B981); 
  static const Color weaknessColor = Color(0xFFF59E0B); 
  static const Color opportunityColor = Color(0xFF3B82F6); 
  static const Color threatColor = Color(0xFFEF4444); 
  static const Color purpleColor = Color(0xFF8B5CF6); 

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFFC084FC)], // Royal purple / violet PRO gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [bgColor, Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xFAFFFFFF), // Frosted white base
      Color(0xE6FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: bgColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: cardColor,
        error: threatColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryTextColor),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.black.withOpacity(0.045), width: 1),
        ),
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryTextColor,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: secondaryTextColor,
        ),
      ),
    );
  }

  // Helper Glassmorphic Box Decoration adapted for Light Theme
  static BoxDecoration glassBox({
    BorderRadius? borderRadius,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.85),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(
        color: borderColor ?? Colors.black.withOpacity(0.045),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
