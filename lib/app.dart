import 'package:flutter/material.dart';

import 'package:lift_off/core/theme/app_theme.dart';
import 'package:lift_off/features/home/home_screen.dart';

class LiftOffApp extends StatelessWidget {
  const LiftOffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lift Off',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: const HomeScreen(),
    );
  }
}
