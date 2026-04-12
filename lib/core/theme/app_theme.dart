import 'package:flutter/material.dart';

// Fallback neutral gradient for any card that isn't tinted by id.
const Color kCardGradientTop = Color(0xFF1C1826);
const Color kCardGradientBottom = Color(0xFF121016);
const Color kCardBorder = Color(0x14FFFFFF); // white @ ~8%
const double kCardRadius = 14;

// Bold per-exercise card gradients. Picked by id via gradientForId().
const List<LinearGradient> kCardPalette = [
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E1A4D), Color(0xFF0F0820)], // deep purple
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F4D), Color(0xFF080B20)], // indigo
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F3340), Color(0xFF04141A)], // teal-black
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A0F1E), Color(0xFF18060C)], // crimson
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A2810), Color(0xFF18100A)], // amber-char
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0E3320), Color(0xFF061A0E)], // forest
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3A1A2E), Color(0xFF180810)], // rose-mauve
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2940), Color(0xFF080F1A)], // slate-blue
  ),
];

LinearGradient gradientForId(int id) =>
    kCardPalette[id.abs() % kCardPalette.length];

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
