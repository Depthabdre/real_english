import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class StoryGenerationLoader extends StatefulWidget {
  const StoryGenerationLoader({super.key});

  @override
  State<StoryGenerationLoader> createState() => _StoryGenerationLoaderState();
}

class _StoryGenerationLoaderState extends State<StoryGenerationLoader>
    with TickerProviderStateMixin {
  int _currentStepIndex = 0;
  Timer? _timer;

  // Animation Controllers for the "Magic Circle" effect
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  final List<String> _loadingPhrases = [
    "Preparing your story segment...",
    "Organizing narrative elements...",
    "Formulating language challenges...",
    "Structuring comprehension questions...",
    "Refining the text for clarity...",
    "Finalizing your interactive lesson...",
  ];

  @override
  void initState() {
    super.initState();

    // 1. Text Cycle Timer
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _currentStepIndex = (_currentStepIndex + 1) % _loadingPhrases.length;
        });
      }
    });

    // 2. Slow Rotation Animation (For the outer ring)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // 3. Pulse Animation (For the inner glow/icon)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Detect Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Select Background Asset based on Theme
    final backgroundAsset = isDark
        ? 'assets/images/adventure_background5.png'
        : 'assets/images/adventure_background6.png';

    // 3. Define Colors based on Theme (Cyan/Blue for Dark, Deep Blue/Amber for Light)
    final accentColor = isDark
        ? const Color(0xFF64FFDA)
        : const Color(0xFF1976D2); // Cyan vs Blue
    final textColor = isDark ? Colors.white : const Color(0xFF212121);
    final glowColor = isDark
        ? const Color(0xFF64FFDA).withValues(alpha: 0.3)
        : Colors.blue.withValues(alpha: 0.2);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // -----------------------------------------------------------
          // LAYER 1: Background Image + Overlay
          // -----------------------------------------------------------
          Image.asset(
            backgroundAsset,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: isDark ? const Color(0xFF0B0E14) : const Color(0xFFF5F5F5),
            ),
          ),

          // Dark/Light Overlay for readability
          Container(
            color: isDark
                ? const Color(0xFF0B0E14).withValues(
                    alpha: 0.85,
                  ) // Deep Dark Overlay
                : Colors.white.withValues(alpha: 0.85), // Milky White Overlay
          ),

          // -----------------------------------------------------------
          // LAYER 2: Main Content
          // -----------------------------------------------------------
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. The Magic Compass / Icon
              SizedBox(
                width: 200,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // A. Rotating Outer Ring (The "Rune Circle")
                    RotationTransition(
                      turns: _rotationController,
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        // Add some "runes" or dots on the ring
                        child: CustomPaint(
                          painter: RuneCirclePainter(color: accentColor),
                        ),
                      ),
                    ),

                    // B. Pulsing Inner Glow
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: glowColor,
                                blurRadius: 20 + (10 * _pulseController.value),
                                spreadRadius: 5 + (5 * _pulseController.value),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // C. The Central Icon (Book + Compass Star)
                    Icon(
                      Icons.auto_stories_rounded, // Book Icon
                      size: 60,
                      color: accentColor,
                    ),
                    // Compass Points overlay (Custom Icon or combination)
                    IgnorePointer(
                      child: Icon(
                        Icons.explore_outlined, // Compass overlay
                        size: 100,
                        color: accentColor.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // 2. The Animated Text ("Forging Your Story...")
              SizedBox(
                height: 60,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                  child: Text(
                    _loadingPhrases[_currentStepIndex],
                    key: ValueKey<String>(_loadingPhrases[_currentStepIndex]),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Georgia', // Serif for "Story" feel
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Dots animation (Simple Text)
              Text(
                ". . .",
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.6),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              // 3. The Cyan/Blue Progress Bar
              Container(
                width: 200,
                height: 6,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Custom Painter to draw the "Rune" details on the ring ---
class RuneCirclePainter extends CustomPainter {
  final Color color;
  RuneCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Draw 4 cardinal points (North, South, East, West triangles)
    for (int i = 0; i < 4; i++) {
      final angle = (i * 90) * (math.pi / 180);
      final markerRadius = 6.0;

      final dx = center.dx + (radius * math.cos(angle));
      final dy = center.dy + (radius * math.sin(angle));

      canvas.drawCircle(Offset(dx, dy), markerRadius, paint);
    }

    // Draw smaller dots in between
    final smallPaint = Paint()..color = color.withValues(alpha: 0.3);
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (math.pi / 180);
      if (i % 2 == 0) continue; // Skip cardinal points

      final dx = center.dx + (radius * math.cos(angle));
      final dy = center.dy + (radius * math.sin(angle));

      canvas.drawCircle(Offset(dx, dy), 3.0, smallPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
