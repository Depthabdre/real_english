import 'package:flutter/material.dart';

class AppTheme {
  // 🌞 Light Theme
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF9FAFB),
    primaryColor: const Color(0xFF1976D2),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF1976D2),
      secondary: Color(0xFFFFC107),
      surface: Colors.white,
    ),
    cardColor: Colors.white,
    shadowColor: const Color(0xFFE0E0E0),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF212121)),
      bodyMedium: TextStyle(color: Color(0xFF616161)),
      titleLarge: TextStyle(
        color: Color(0xFF212121),
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );

  // 🌙 Dark Theme
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D1117),
    primaryColor: const Color(0xFF64B5F6),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF64B5F6),
      secondary: Color(0xFFFFCA28),
      surface: Color(0xFF1E1E1E),
    ),
    cardColor: const Color(0xFF1E1E1E),
    shadowColor: Colors.transparent,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF64B5F6),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
  );
}
