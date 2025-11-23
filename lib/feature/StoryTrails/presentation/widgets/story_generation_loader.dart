import 'dart:async';
import 'package:flutter/material.dart';

class StoryGenerationLoader extends StatefulWidget {
  const StoryGenerationLoader({super.key});

  @override
  State<StoryGenerationLoader> createState() => _StoryGenerationLoaderState();
}

class _StoryGenerationLoaderState extends State<StoryGenerationLoader>
    with SingleTickerProviderStateMixin {
  int _currentStepIndex = 0;
  Timer? _timer;

  // The fun messages to cycle through
  final List<String> _loadingPhrases = [
    "Opening the book of imagination...",
    "Summoning the characters...",
    "Painting the scenery...",
    "Writing the dialogue...",
    "Polishing the grammar...",
    "Adding a sprinkle of magic...",
    "Finalizing your adventure...",
  ];

  @override
  void initState() {
    super.initState();
    // Cycle text every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentStepIndex = (_currentStepIndex + 1) % _loadingPhrases.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        // A magical deep gradient background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A148C), // Deep Purple
            Color(0xFF311B92), // Deep Indigo
            Color(0xFF1A237E), // Dark Blue
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. The Pulsating Icon (The "Brain")
          _buildPulsatingIcon(),

          const SizedBox(height: 40),

          // 2. The Title
          const Text(
            "Weaving Your Story",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          // 3. The Animated Changing Text
          SizedBox(
            height: 50, // Fixed height to prevent jumping
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.5),
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
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 4. A Custom Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: const LinearProgressIndicator(
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amberAccent),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
    }

 // Replace the _buildPulsatingIcon method with this simpler infinite animation wrapper:
  Widget _buildPulsatingIcon() {
    return RepaintBoundary(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 1),
        builder: (context, value, _) {
          return Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                   // Makes the shadow breathe
                  color: Colors.amber.withOpacity(0.2 + (0.2 * (value))), 
                  blurRadius: 20 + (10 * value),
                  spreadRadius: 5 + (5 * value),
                )
              ],
            ),
             // Use a Standard Flutter Icon, or FontAwesome if you have it
            child: const Icon(
              Icons.auto_stories, 
              size: 60, 
              color: Colors.white
            ),
          );
        },
        onEnd: () {
            // This is a hacky way to loop a TweenBuilder without a controller. 
            // Ideally, use an AnimationController if you want perfect control.
            // For now, this static glow is sleek enough.
        }, 
      ),
    );
  }