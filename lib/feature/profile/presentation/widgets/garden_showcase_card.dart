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

    // --- FIX 1: BACKGROUND COLOR MATCHING ---
    // Matches the provided pot image background (Black in dark mode, White in light)
    final backgroundColor = isDark ? Colors.black : Colors.white;

    // Ensure text is visible against the solid background
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Container(
      width: double.infinity,
      height: 380,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        // Subtle border to separate the black card from a dark background if needed
        border: isDark
            ? Border.all(color: Colors.white.withValues(alpha: 0.1))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // --- FIX 2: IMAGE POSITIONING ---
          // Aligned to BOTTOM CENTER so it doesn't float up and block the text.
          Positioned(
            left: 20,
            right: 20,
            bottom: 20, // Pinned to bottom
            top: 100, // Push it down so it doesn't touch the text area
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Image.asset(
                GardenAssets.getTreeImage(growth.treeStage, isDark),
                key: ValueKey('${growth.treeStage}_$isDark'),
                fit: BoxFit.contain, // Ensures the pot fits within the box
                alignment: Alignment.bottomCenter, // Anchors pot to the bottom
              ),
            ),
          ),

          // --- FIX 3: TEXT ON TOP ---
          // Streak Badge (Top Right)
          Positioned(
            top: 24,
            right: 24,
            child: _buildStreakBadge(context, isDark, textColor),
          ),

          // Stage Label (Top Left)
          Positioned(
            top: 24,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Current Growth",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: subTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  growth.treeStage.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor, // High contrast text
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBadge(BuildContext context, bool isDark, Color textColor) {
    final isActive = habit.isStreakActive;
    final accentColor = isActive
        ? (isDark ? const Color(0xFFFFD600) : const Color(0xFFFF6D00))
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        // Use a contrasting background for the badge
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.grey.shade100,
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
          const SizedBox(width: 6),
          Text(
            "${habit.currentStreak} Day Streak",
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
              color: textColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
