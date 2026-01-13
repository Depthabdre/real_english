import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/immersion_short.dart';
import '../bloc/immersion_bloc.dart';

class ImmersionOverlayContent extends StatelessWidget {
  final ImmersionShort short;

  const ImmersionOverlayContent({super.key, required this.short});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // This Spacer pushes everything to the bottom of the screen
            const Spacer(),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // -------------------------------------------------------
                // LEFT SIDE: Text Context
                // -------------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Difficulty Badge
                      _buildDifficultyBadge(short.difficultyLabel),
                      const SizedBox(height: 12),

                      // Title (Friendly Font)
                      Text(
                        short.title,
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.1,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Smart Tags
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTag(short.category),
                          _buildTag("English"),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 16),

                // -------------------------------------------------------
                // RIGHT SIDE: Action Buttons
                // -------------------------------------------------------
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSaveButton(context),
                    const SizedBox(height: 24),
                    _buildGotItButton(context),
                    // Align buttons slightly with text baseline
                    const SizedBox(height: 10),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildDifficultyBadge(String level) {
    final color = switch (level.toLowerCase()) {
      'beginner' => const Color(0xFF66BB6A), // Green
      'advanced' => const Color(0xFFEF5350), // Red
      _ => const Color(0xFFFFA726), // Orange
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.spa_rounded, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            level.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Nunito',
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "#$text",
        style: const TextStyle(
          fontFamily: 'Nunito',
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ImmersionBloc>().add(ToggleSaveShort(short.id));
      },
      child: Column(
        children: [
          // Glassmorphism Circle
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  short.isSaved
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: short.isSaved ? const Color(0xFFFF6584) : Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Keep",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGotItButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ImmersionBloc>().add(MarkShortAsWatched(short.id));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Absorbed! +5 XP",
              style: TextStyle(fontFamily: 'Fredoka'),
            ),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(milliseconds: 800),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        children: [
          // "Reward" style button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50), // Growth Green
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Got it",
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
        ],
      ),
    );
  }
}
