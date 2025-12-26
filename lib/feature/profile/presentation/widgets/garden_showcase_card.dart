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
      height: 380,
      decoration: BoxDecoration(
        // CONSISTENT CARD COLOR (No Gradient)
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: isDark ? Border.all(color: Colors.white10) : null,
        // Standard Shadow similar to other cards
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Stack(
        children: [
          // 1. Streak Badge
          Positioned(
            top: 24,
            right: 24,
            child: _buildStreakBadge(context, isDark),
          ),

          // 2. Stage Label
          Positioned(
            top: 24,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Stage",
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  growth.treeStage.replaceAll('_', ' ').toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    // Use primary color in light mode, white in dark
                    color: isDark ? Colors.white : theme.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // 3. The Tree
          Positioned(
            top: 100,
            bottom: 20,
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

  Widget _buildStreakBadge(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final isActive = habit.isStreakActive;

    final accentColor = isActive
        ? (isDark ? const Color(0xFFFFD600) : const Color(0xFFFF6D00))
        : Colors.grey;

    // Use a subtle background for the badge so it stands out on the card
    final backgroundColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : theme.scaffoldBackgroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            GardenAssets.getCelestialIcon(isDark, isActive),
            color: accentColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "${habit.currentStreak} Day Streak",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: theme.textTheme.bodyLarge?.color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
