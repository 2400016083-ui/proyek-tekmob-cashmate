import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF16A34A);
  static const Color primaryDark = Color(0xFF15803D);
  static const Color primaryLight = Color(0xFFE8F5E9);

  // Secondary
  static const Color secondary = Color(0xFF22C55E);

  // Background
  static const Color background = Color(0xFFF8FAF9);
  static const Color surface = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Status
  static const Color income = Color(0xFF16A34A);
  static const Color expense = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);

  // Border
  static const Color border = Color(0xFFE5E7EB);

  // Shadow
  static const Color shadow = Color(0x14000000);

  // Fixed palette for category charts (Firestore data has no Color field)
  static const List<Color> chartPalette = [
    Color(0xFFDC2626),
    Color(0xFF16A34A),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];
}