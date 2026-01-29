import 'package:flutter/material.dart';

class AppColors {
  // Primary Healthcare Colors
  static const Color primary = Color(0xFF0D47A1); // Deep Medical Blue
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0A3D91);

  // Accent Colors (Healthcare specific)
  static const Color emergency = Color(0xFFD32F2F); // Emergency Red
  static const Color success = Color(0xFF00897B); // Teal (Medical)
  static const Color warning = Color(0xFFF57C00); // Orange Alert
  static const Color info = Color(0xFF1976D2); // Info Blue
  
  // Status Colors
  static const Color statusActive = Color(0xFF00897B);
  static const Color statusPending = Color(0xFFFFA726);
  static const Color statusCompleted = Color(0xFF66BB6A);
  static const Color statusError = Color(0xFFEF5350);

  // Neutral Colors
  static const Color textPrimary = Color(0xFF1A237E);
  static const Color textSecondary = Color(0xFF455A64);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFECEFF1);
}

class AppStyles {
  // AppBar Style
  static AppBarTheme appBarTheme() {
    return AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  // Card Shadow
  static List<BoxShadow> cardShadow() {
    return [
      BoxShadow(
        color: Colors.grey.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
}