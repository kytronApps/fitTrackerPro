import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Fondo global
      scaffoldBackgroundColor: AppColors.background,

      colorScheme: ColorScheme.light(
        primary: AppColors.bluePrimary,
        secondary: AppColors.purplePrimary,
      ),

      // Textos
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.bluePrimary),
        titleTextStyle: TextStyle(
          color: AppColors.bluePrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Botones de ejemplo
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bluePrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),

      // Inputs / TextFields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
