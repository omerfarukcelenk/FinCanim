import 'package:flutter/material.dart';

// Centralized app theme definitions. Start with a light theme that reuses
// colors already present across the codebase (appbar red, accent reds/pinks,
// soft card backgrounds).

class AppColors {
  static const primary = Color.fromRGBO(203, 12, 45, 1); // appbar
  static const primaryDark = Color.fromRGBO(170, 7, 35, 1);
  static const accent = Color.fromRGBO(255, 198, 198, 1);
  static const surface = Color.fromRGBO(255, 250, 250, 1);
  static const card = Color.fromRGBO(255, 255, 255, 1);
  static const muted = Color.fromRGBO(120, 40, 40, 1);
  static const softBg = Color.fromRGBO(250, 248, 248, 1);
}

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.softBg,
  shadowColor: Colors.black54,
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.primaryDark,
    surface: AppColors.card,
    onPrimary: Colors.white,
    onSurface: Colors.black87,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: false,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryDark,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
  ),
  cardColor: AppColors.card,
  dialogTheme: const DialogThemeData(backgroundColor: AppColors.card),
  canvasColor: Colors.white,
  dividerColor: Colors.grey[200],
  iconTheme: const IconThemeData(color: AppColors.muted),
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black87),
    titleMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
    labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
  bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.white),
);

// Detailed dark theme using the same brand accents but adapted for high
// contrast on dark surfaces.
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: const Color.fromARGB(255, 37, 37, 37),
  shadowColor: Colors.white,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.primaryDark,
    surface: Color(0xFF1E1E1E),
    onPrimary: Colors.white,
    onSurface: Colors.white70,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF141212),
    foregroundColor: Colors.white,
    elevation: 1,
    centerTitle: false,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
  ),
  cardColor: const Color(0xFF151515),
  dialogTheme: const DialogThemeData(backgroundColor: Color(0xFF121212)),
  canvasColor: const Color(0xFF0B0B0B),
  dividerColor: Colors.grey[800],
  iconTheme: const IconThemeData(color: Colors.white70),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 20.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white70),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white70),
    titleMedium: TextStyle(fontSize: 14.0, color: Colors.white60),
    labelLarge: TextStyle(
      fontSize: 14.0,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1B1B1B),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Color(0xFF0F0F0F),
  ),
);
