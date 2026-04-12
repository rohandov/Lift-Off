import 'package:flutter/material.dart';

import 'package:lift_off/core/theme/app_theme.dart';

/// Card-shaped surface with a subtle diagonal gradient.
///
/// Mimics the app's [Card] shape (radius, hairline border, zero elevation)
/// but backed by a [LinearGradient] instead of a solid color.
class GradientCard extends StatelessWidget {
  const GradientCard({
    super.key,
    required this.child,
    this.clipBehavior = Clip.antiAlias,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  });

  final Widget child;
  final Clip clipBehavior;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Material(
        color: Colors.transparent,
        clipBehavior: clipBehavior,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kCardRadius),
          side: const BorderSide(color: kCardBorder),
        ),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kCardGradientTop, kCardGradientBottom],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
