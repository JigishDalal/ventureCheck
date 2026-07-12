import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color bgColor = Color(0xFFF3F4F6); // App Background (Light Grey)
  static const Color cardColor = Color(0xFFFFFFFF); // Card / Form Surface (Pure White)
  static const Color primaryColor = Color(0xFF00B4DB); // Gradient Start (Cyan)
  static const Color secondaryColor = Color(0xFF08C299); // Gradient End (Green)
  static const Color accentColor = Color(0xFF10B981); // Success Checkmarks (Solid Green)
  static const Color darkSurfaceColor = Color(0xFF1F2937); // Sidebar / Dark Surface (Dark Charcoal)

  // Typography / Text Colors
  static const Color primaryTextColor = Color(0xFF111827); // Primary Text / Headings (Dark Charcoal)
  static const Color secondaryTextColor = Color(0xFF6B7280); // Secondary Text / Subtitles (Slate)

  // UI Element Colors for Light Theme (allows const usage)
  static const Color dividerColor = Color(0x14000000); // 8% opacity black
  static const Color borderLightColor = Color(0x0F000000); // 6% opacity black
  static const Color borderMediumColor = Color(0x1F000000); // 12% opacity black

  // SWOT & Contextual Colors
  static const Color strengthColor = Color(0xFF10B981); // Success Green
  static const Color weaknessColor = Color(0xFFF59E0B); // Warning Gold/Yellow
  static const Color opportunityColor = Color(0xFF3B82F6); // Info Solid Blue
  static const Color threatColor = Color(0xFFEF4444); // Threat Solid Red
  static const Color purpleColor = Color(0xFF8B5CF6); // Deep Analysis (Purple)

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [bgColor, Color(0xFFE5E7EB)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0xCCFFFFFF), // Opaque white base for light mode glassmorphism
      Color(0x66FFFFFF),
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
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x1F000000)), // subtle border
        ),
        elevation: 2,
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
      color: Colors.white.withOpacity(0.7), // Semi-opaque white for contrast on light background
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: borderColor ?? Colors.black.withOpacity(0.06), // Subtle dark border
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
