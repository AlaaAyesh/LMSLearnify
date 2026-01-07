import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Global Cairo font family - use this instead of hardcoded 'Cairo'
String get cairoFontFamily => GoogleFonts.cairo().fontFamily!;

class AppTextStyles {
  // Get Cairo font family name from Google Fonts
  static String get _cairoFamily => cairoFontFamily;

  // Display Styles
  static TextStyle get displayLarge => TextStyle(
    fontFamily: _cairoFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: _cairoFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // Headline Styles
  static TextStyle get headlineLarge => TextStyle(
    fontFamily: _cairoFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: _cairoFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Styles
  static TextStyle get bodyLarge => TextStyle(
    fontFamily: _cairoFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: _cairoFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Label Styles
  static TextStyle get labelLarge => TextStyle(
    fontFamily: _cairoFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: _cairoFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // Button Styles
  static TextStyle get button => TextStyle(
    fontFamily: _cairoFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}



