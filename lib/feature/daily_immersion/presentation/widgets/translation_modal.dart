import 'dart:ui';
import 'package:flutter/material.dart';

class TranslationModal extends StatelessWidget {
  final String title;
  final String description;

  const TranslationModal({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    // Center the modal but keep it above where the finger typically is
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.9,
              ), // Slightly translucent white
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                const Icon(
                  Icons.translate_rounded,
                  size: 40,
                  color: Color(0xFF1976D2),
                ),
                const SizedBox(height: 16),

                // English Text
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 12),
                Divider(color: Colors.grey.withValues(alpha: 0.3)),
                const SizedBox(height: 12),

                // "Translation" / Context
                Text(
                  description.isNotEmpty
                      ? description
                      : "Listen closely to the rhythm.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    color: Color(0xFF1976D2), // Brand Blue
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 20),

                // Hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 16,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Release to resume",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
