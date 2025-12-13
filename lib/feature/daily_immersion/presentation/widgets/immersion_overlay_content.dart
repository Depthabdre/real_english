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
            // Spacer to push everything down
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

                      // Title
                      Text(
                        short.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Smart Tags
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTag(short.category),
                          _buildTag("English"),
                        ],
                      ),
                      const SizedBox(height: 12), // Spacing for progress bar
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
                    const SizedBox(height: 12), // Spacing for progress bar
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String level) {
    final color = switch (level.toLowerCase()) {
      'beginner' => const Color(0xFF66BB6A), // Green
      'advanced' => const Color(0xFFEF5350), // Red
      _ => const Color(0xFFFFA726), // Orange (Intermediate)
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            level.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        "#$text",
        style: const TextStyle(color: Colors.white70, fontSize: 12),
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: Icon(
              short.isSaved ? Icons.favorite : Icons.favorite_border,
              color: short.isSaved ? Colors.pinkAccent : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Save",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildGotItButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ImmersionBloc>().add(MarkShortAsWatched(short.id));
        // Optional: Trigger a small confetti or "Thumbs up" animation here
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Great! Algorithm updated."),
            duration: Duration(milliseconds: 800),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF66BB6A), // Success Green
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          const Text(
            "I got it",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
