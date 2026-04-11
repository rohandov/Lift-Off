import 'package:flutter/material.dart';

/// Maps the handful of icon names we use in the seed data and custom-add sheet
/// to actual `IconData` values. Keeping this tiny keeps our app tree-shakable.
const Map<String, IconData> kIconChoices = {
  'fitness_center': Icons.fitness_center,
  'accessibility_new': Icons.accessibility_new,
  'timer': Icons.timer_outlined,
  'directions_walk': Icons.directions_walk,
  'sports_gymnastics': Icons.sports_gymnastics,
  'star': Icons.star,
  'bolt': Icons.bolt,
  'self_improvement': Icons.self_improvement,
};

IconData iconFor(String name) =>
    kIconChoices[name] ?? Icons.fitness_center;
