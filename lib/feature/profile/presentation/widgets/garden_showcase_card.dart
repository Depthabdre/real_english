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
      height: 320,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        // Subtle shadow in Light mode, no shadow in Dark mode (as per theme)
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
        border: isDark ? Border.all(color: Colors.white10) : null,
      ),
      child: Stack(
        children: [
          // 1. Streak Indicator (Top Right)
          Positioned(top: 20, right: 20, child: _buildStreakBadge(context)),

          // 2. The Tree (Centered & Bottom)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            top: 60,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Image.asset(
                GardenAssets.getTreeImage(growth.treeStage),
                key: ValueKey(growth.treeStage),
                fit: BoxFit.contain,
              ),
            ),
          ),

          // 3. Stage Label (Top Left)
          Positioned(
            top: 24,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Growth",
                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                ),
                Text(
                  growth.treeStage.replaceAll('_', ' ').toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 16,
                    color: theme.primaryColor,
                    letterSpacing: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = habit.isStreakActive;
    final color = isActive ? theme.colorScheme.secondary : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department_rounded, color: color, size: 18),
          const SizedBox(width: 4),
          Text(
            "${habit.currentStreak} Day Streak",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
