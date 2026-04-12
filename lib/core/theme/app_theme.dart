import 'package:flutter/material.dart';

// Subdued purple-charcoal gradient used on all card surfaces.
const Color kCardGradientTop = Color(0xFF1C1826);
const Color kCardGradientBottom = Color(0xFF121016);
const Color kCardBorder = Color(0x14FFFFFF); // white @ ~8%
const double kCardRadius = 14;

class AppTheme {
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4ADE80),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B0B0F),
      cardTheme: CardThemeData(
        color: kCardGradientTop,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
          side: const BorderSide(color: kCardBorder),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
