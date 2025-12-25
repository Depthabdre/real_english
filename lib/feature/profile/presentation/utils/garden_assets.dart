import 'package:flutter/material.dart';

class GardenAssets {
  // Tree Images (PNGs with Light/Dark variants)
  static String getTreeImage(String stage, bool isDark) {
    final suffix = isDark ? 'dark' : 'light';
    switch (stage) {
      case 'seed':
        return 'assets/garden/tree_0_seed_$suffix.png';
      case 'sprout':
        return 'assets/garden/tree_1_sprout_$suffix.png';
      case 'sapling':
        return 'assets/garden/tree_2_sapling_$suffix.png';
      case 'young_tree':
        return 'assets/garden/tree_3_young_$suffix.png';
      case 'majestic_tree':
        return 'assets/garden/tree_4_majestic_$suffix.png';
      default:
        return 'assets/garden/tree_0_seed_$suffix.png';
    }
  }

  // Streak Icons (Native Flutter Icons)
  static IconData getCelestialIcon(bool isDark, bool isActive) {
    if (isDark) {
      // Night: Solid Moon if active, Outlined/Dim if inactive
      return isActive ? Icons.nightlight_round : Icons.nightlight_outlined;
    } else {
      // Day: Sunny if active, Cloudy if inactive
      return isActive ? Icons.wb_sunny_rounded : Icons.wb_cloudy_rounded;
    }
  }
}
