import 'package:flutter/material.dart';
import '../../domain/entities/user_profile.dart';
import '../utils/garden_assets.dart';

class GardenShowcaseCard extends StatelessWidget {
  final ProfileGrowth growth;
  final ProfileHabit habit;

  const GardenShowcaseCard({
    super.key,
    required this.growth,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: 380, // Height for spacing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        // Minimalist Shadow
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black26
                : const Color(0xFF1976D2).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        // Atmospheric Gradient (Day vs Night)
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF121212)] // Night
              : [const Color(0xFFE3F2FD), const Color(0xFFFFFFFF)], // Day
        ),
      ),
      child: Stack(
        children: [
          // ------------------------------------------
          // 1. Streak Badge (Top Right) - ICON BASED
          // ------------------------------------------
          Positioned(
            top: 28,
            right: 28,
            child: _buildStreakBadge(context, isDark),
          ),

          // ------------------------------------------
          // 2. Stage Text (Top Left)
          // ------------------------------------------
          Positioned(
            top: 28,
            left: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Growth",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white60 : Colors.blueGrey,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  growth.treeStage.replaceAll('_', ' ').toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : theme.primaryColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------
          // 3. The Tree (Bottom)
          // ------------------------------------------
          Positioned(
            top: 100, // Push down to create gap
            bottom: 0,
            left: 20,
            right: 20,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: Image.asset(
                GardenAssets.getTreeImage(growth.treeStage, isDark),
                key: ValueKey('${growth.treeStage}_$isDark'),
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🌟 Streak Badge using ICONS
  Widget _buildStreakBadge(BuildContext context, bool isDark) {
    final isActive = habit.isStreakActive;

    // 1. Color Logic
    // Active: Amber/Orange
    // Inactive: Grey
    final accentColor = isActive
        ? (isDark ? const Color(0xFFFFD600) : const Color(0xFFFF6D00))
        : Colors.grey;

    // 2. Background Logic (High Contrast against sky)
    final backgroundColor = isDark
        ? Colors.black.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.9);

    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // THE ICON (From GardenAssets)
          Icon(
            GardenAssets.getCelestialIcon(isDark, isActive),
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          // THE TEXT
          Text(
            "${habit.currentStreak} Day Streak",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
