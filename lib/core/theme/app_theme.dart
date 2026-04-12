import 'package:flutter/material.dart';

// Fallback neutral gradient for any card that isn't tinted by id.
const Color kCardGradientTop = Color(0xFF3D2A5C);
const Color kCardGradientBottom = Color(0xFF1A1525);
const Color kCardBorder = Color(0x14FFFFFF); // white @ ~8%
const double kCardRadius = 14;

// Bold per-exercise card gradients. Picked by id via gradientForId().
const List<LinearGradient> kCardPalette = [
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5C35A0), Color(0xFF1A1030)], // deep purple
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3540A0), Color(0xFF121530)], // indigo
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E6680), Color(0xFF0A2028)], // teal
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7A2040), Color(0xFF280E18)], // crimson
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7A5020), Color(0xFF281A10)], // amber
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C6640), Color(0xFF0E2818)], // forest
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7A3560), Color(0xFF281420)], // rose-mauve
  ),
  LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF355280), Color(0xFF121E30)], // slate-blue
  ),
];

LinearGradient gradientForId(int id) =>
    kCardPalette[id.abs() % kCardPalette.length];

class GradientTitle extends StatelessWidget {
  const GradientTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFF9B59B6), Color(0xFF4ADE80)],
      ).createShader(bounds),
      child: const Text(
        'Lift Off',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

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
