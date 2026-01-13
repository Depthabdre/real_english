import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class StoryAlchemyLoader extends StatefulWidget {
  const StoryAlchemyLoader({super.key});

  @override
  State<StoryAlchemyLoader> createState() => _StoryAlchemyLoaderState();
}

class _StoryAlchemyLoaderState extends State<StoryAlchemyLoader>
    with TickerProviderStateMixin {
  // Simplified, clear steps for the animation
  final List<_StoryIngredient> _ingredients = [
    _StoryIngredient("Creating the world...", Icons.landscape_rounded),
    _StoryIngredient("Adding characters...", Icons.face_rounded),
    _StoryIngredient("Writing dialogue...", Icons.chat_bubble_outline_rounded),
    _StoryIngredient("Adding details...", Icons.auto_awesome_rounded),
    _StoryIngredient("Almost done...", Icons.menu_book_rounded),
  ];

  int _currentIndex = 0;
  Timer? _cycleTimer;

  // Animation Controllers
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late AnimationController _dropController;

  @override
  void initState() {
    super.initState();

    // 1. Pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // 2. Orbit
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // 3. Drop
    _dropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _startIngredientCycle();
  }

  void _startIngredientCycle() {
    _dropController.forward(from: 0.0);

    _cycleTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          if (_currentIndex < _ingredients.length - 1) {
            _currentIndex++;
            _dropController.forward(from: 0.0);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _pulseController.dispose();
    _orbitController.dispose();
    _dropController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Background (Subtle)
          Positioned.fill(
            child: CustomPaint(
              painter: ParticleOrbitPainter(
                animation: _orbitController,
                color: primaryColor.withValues(alpha: 0.05),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Center Everything
                children: [
                  // ---------------------------------------------------
                  // 2. CLEAR HEADER (Simple English)
                  // ---------------------------------------------------
                  Text(
                    "Preparing Your Story",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Please wait, this takes a few seconds.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 50),

                  // ---------------------------------------------------
                  // 3. THE VISUAL ANIMATION
                  // ---------------------------------------------------
                  SizedBox(
                    height: 250,
                    width: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // A. Ripple
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 140 + (_pulseController.value * 20),
                              height: 140 + (_pulseController.value * 20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryColor.withValues(
                                    alpha: 0.2 - (_pulseController.value * 0.2),
                                  ),
                                  width: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        // B. Book Icon
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.15),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            size: 60,
                            color: primaryColor,
                          ),
                        ),
                        // C. Falling Icon
                        AnimatedBuilder(
                          animation: _dropController,
                          builder: (context, child) {
                            final val = _dropController.value;
                            final double dy = -100 + (100 * val);
                            final double opacity = val > 0.8
                                ? (1.0 - val) * 5
                                : 1.0;
                            final double scale = 1.0 - (val * 0.5);

                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: Transform.scale(
                                scale: scale,
                                child: Opacity(
                                  opacity: opacity.clamp(0.0, 1.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondary,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: theme.colorScheme.secondary
                                              .withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      _ingredients[_currentIndex].icon,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ---------------------------------------------------
                  // 4. CURRENT STATUS TEXT
                  // ---------------------------------------------------
                  SizedBox(
                    height: 40,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _ingredients[_currentIndex].text,
                        key: ValueKey<int>(_currentIndex),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Progress Bar
                  Container(
                    width: 160,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (_currentIndex + 1) / _ingredients.length,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryIngredient {
  final String text;
  final IconData icon;
  _StoryIngredient(this.text, this.icon);
}

class ParticleOrbitPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  ParticleOrbitPainter({required this.animation, required this.color})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..color = color;

    for (int i = 0; i < 3; i++) {
      final double angle =
          (animation.value * 2 * math.pi) + (i * (2 * math.pi / 3));
      final double orbitRadius = 130.0 + (i * 20);

      final dx = center.dx + math.cos(angle) * orbitRadius;
      final dy = center.dy + math.sin(angle) * orbitRadius;

      canvas.drawCircle(Offset(dx, dy), 5.0, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
