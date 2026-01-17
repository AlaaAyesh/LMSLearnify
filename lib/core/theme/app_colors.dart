import 'package:flutter/material.dart';

class AppColors {
  // Private constructor - this is a utility class
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFFFDB914); // اللون الأصفر من التصميم
  static const Color primaryCard = Color(0xFFFFF2D9);
  static const Color soonText = Color.fromRGBO(255, 159, 25, 1);
  // rgb(255, 242, 217)
  static const Color primaryDark = Color(0xFFE5A000);
  static const Color primaryLight = Color(0xFFFFC847);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundLight = Color(0xFFF8F9FA);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF95A5A6);
  static const Color greyLight = Color(0xFFDFE6E9);

  // Status Colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFD63031);
  static const Color warning = Color(0xFFFDAA33);
  static const Color info = Color(0xFF0984E3);

  // Input Colors
  static const Color inputBackground = Color(0xFFF8F9FA);
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFocusBorder = Color(0xFFFDB914);

  // Pre-computed opacity colors (avoid creating new Color objects in build)
  static const Color primaryOpacity10 = Color(0x1AFDB914);
  static const Color primaryOpacity30 = Color(0x4DFDB914);
  static const Color primaryOpacity50 = Color(0x80FDB914);
  
  static const Color blackOpacity30 = Color(0x4D000000);
  static const Color blackOpacity50 = Color(0x80000000);
  static const Color blackOpacity60 = Color(0x99000000);
  static const Color blackOpacity70 = Color(0xB3000000);
  static const Color blackOpacity90 = Color(0xE6000000);
  
  static const Color whiteOpacity15 = Color(0x26FFFFFF);
  static const Color whiteOpacity60 = Color(0x99FFFFFF);
  static const Color whiteOpacity80 = Color(0xCCFFFFFF);
}


