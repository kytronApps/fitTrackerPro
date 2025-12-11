import 'package:flutter/material.dart';

class AppColors {
  // --- PRIMARIOS ---
  static const Color bluePrimary = Color(0xFF1363DF);
  static const Color purplePrimary = Color(0xFF6D0AD3);

  // --- GRADIENTES PRINCIPALES ---
  static const Gradient adminGradient = LinearGradient(
    colors: [
      Color(0xFF9D0AF5),
      Color(0xFF5508E5),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient userGradient = LinearGradient(
    colors: [
      Color(0xFF0F6BFF),
      Color(0xFF014FFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- TEXTO ---
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF8D8D8D);

  // --- FONDOS ---
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F7F7);

  // --- TAG COLORS ---
  static const Color tagWorkout = Color(0xFFE8EFFF);   // Entrenamiento
  static const Color tagNutrition = Color(0xFFE3F9E5); // Nutrición
  static const Color tagProgress = Color(0xFFF3E8FF);  // Progreso
}
