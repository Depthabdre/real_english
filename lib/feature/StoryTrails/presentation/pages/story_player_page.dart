import 'dart:async';
import 'dart:ui'; // For ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/feature/StoryTrails/presentation/widgets/robust_story_image.dart';

import '../../../../app/injection_container.dart';
import '../../domain/entities/single_choice_challenge.dart';
import '../../domain/entities/story_segment.dart';
import '../bloc/story_player_bloc.dart';

class StoryPlayerPage extends StatelessWidget {
  final String trailId;
  const StoryPlayerPage({super.key, required this.trailId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoryPlayerBloc>(
      create: (context) =>
          sl<StoryPlayerBloc>()..add(StartStory(trailId: trailId)),
      child: const StoryPlayerView(),
    );
  }
}

class StoryPlayerView extends StatefulWidget {
  const StoryPlayerView({super.key});

  @override
  State<StoryPlayerView> createState() => _StoryPlayerViewState();
}

class _StoryPlayerViewState extends State<StoryPlayerView> {
  // Track selected option for Challenges
  String? _selectedChoiceId;

  // --- 1. Persistent Top Feedback Toast ---
  void _showFeedbackToast(
    BuildContext context,
    bool isCorrect,
    String message,
  ) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, -20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                // Green for correct, Red for wrong
                color: isCorrect
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE57373),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect
                        ? Icons.check_circle_outline
                        : Icons.error_outline,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    // Persist for 3 seconds, then remove
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Context-Aware Theme Detection
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dynamic Background Colors
    final bgColor = isDark ? const Color(0xFF0B0E14) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: bgColor,
      // Extend body behind AppBar for immersion
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const BackButton(color: Colors.white),
        ),
        actions: [
          // Optional: Progress indicator or level badge in top right
        ],
      ),
      body: BlocListener<StoryPlayerBloc, StoryPlayerState>(
        listener: (context, state) {
          if (state is AnswerFeedback) {
            _showFeedbackToast(context, state.isCorrect, state.feedbackMessage);
            // Reset selection after feedback
            setState(() {
              _selectedChoiceId = null;
            });
          }
        },
        child: BlocBuilder<StoryPlayerBloc, StoryPlayerState>(
          builder: (context, state) {
            // 1. Loading State
            if (state is StoryPlayerInitial || state is StoryPlayerLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Level Up State
            if (state is LevelCompleted) {
              return _buildLevelCompleted(context, state, isDark);
            }

            // 3. Story Finished State
            if (state is StoryPlayerFinished) {
              return _buildStoryFinished(context, state, isDark);
            }

            // 4. Main Player State
            StorySegment? segment;
            if (state is StoryPlayerDisplay) {
              segment = state.currentSegment;
            } else if (state is AnswerFeedback) {
              segment = state.displayState.currentSegment;
            }

            if (segment != null) {
              return _buildLayout(context, segment, isDark);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // --- Main Layout Strategy ---
  Widget _buildLayout(BuildContext context, StorySegment segment, bool isDark) {
    return Stack(
      children: [
        // 1. Top Image (Full Width, Cinematic)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.60,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            // USE THE NEW WIDGET HERE
            child: RobustStoryImage(
              key: ValueKey(
                segment.imageUrl,
              ), // Important for switching segments
              imageUrl: segment.imageUrl ?? '',
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Gradient Fade ( Seamless blend between image and content)
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                  isDark ? const Color(0xFF0B0E14) : const Color(0xFFF5F5F5),
                ],
                stops: const [0.4, 0.6, 0.9],
              ),
            ),
          ),
        ),

        // 2. The Content Card (Bottom Aligned, Auto-Sized)
        Align(
          alignment: Alignment.bottomCenter,
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                MediaQuery.of(context).padding.bottom + 20,
              ),
              child: _buildGlassCard(context, segment, isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard(
    BuildContext context,
    StorySegment segment,
    bool isDark,
  ) {
    // Card Colors based on Theme
    final cardColor = isDark
        ? const Color(0xFF1E222B).withValues(alpha: 0.95)
        : Colors.white.withValues(alpha: 0.95);
    final textColor = isDark ? Colors.white : const Color(0xFF212121);
    final borderColor = isDark ? Colors.white10 : Colors.black12;

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // "Not too tall", fits content
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: segment.type == SegmentType.choiceChallenge
                    ? _buildChallengeContent(
                        context,
                        segment,
                        textColor,
                        isDark,
                      )
                    : _buildNarrationContent(
                        context,
                        segment,
                        textColor,
                        isDark,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Narration Mode (Text + Controls) ---
  Widget _buildNarrationContent(
    BuildContext context,
    StorySegment segment,
    Color textColor,
    bool isDark,
  ) {
    // 1. Get Data from State
    Duration? audioDuration;
    String? playingId;

    final state = context.read<StoryPlayerBloc>().state;
    if (state is StoryPlayerDisplay) {
      audioDuration = state.currentAudioDuration;
      playingId = state.playingSegmentId;
    }

    // 2. Logic: Should we start typing?
    // If the BLoC hasn't emitted the ID yet (still loading audio), show nothing.
    if (playingId != segment.id) {
      return SizedBox(
        height: 100,
        child: Center(
          // Optional: Tiny loading indicator while buffering audio
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: textColor.withValues(alpha: 0.3),
          ),
        ),
      );
    }

    // 3. Calculate Dynamic Speed
    // Default: 50ms (Generic reading speed)
    Duration typingSpeed = const Duration(milliseconds: 50);

    if (audioDuration != null && segment.textContent.isNotEmpty) {
      // Logic: If audio is 10s (10000ms) and text is 100 chars
      // Speed = 100ms per char.
      // We subtract a tiny buffer (500ms) so text finishes slightly before audio cuts.
      final safeDurationMs = (audioDuration.inMilliseconds - 500).clamp(
        1000,
        999999,
      );
      final msPerChar = safeDurationMs / segment.textContent.length;
      typingSpeed = Duration(milliseconds: msPerChar.round());
    }

    return Column(
      key: ValueKey(segment.id),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Typewriter Text
        SizedBox(
          width: double.infinity,
          child: TypewriterText(
            // The key forces a rebuild if the speed changes (e.g. audio loads late)
            key: ValueKey("${segment.id}_${typingSpeed.inMilliseconds}"),
            text: segment.textContent,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 18,
              height: 1.6,
              color: textColor,
            ),
            typingSpeed: typingSpeed,
          ),
        ),

        const SizedBox(height: 32),

        // Player Controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A303C) : const Color(0xFFF0F4F8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(segment.imageUrl ?? ''),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10_rounded),
                      onPressed: () {
                        context.read<StoryPlayerBloc>().add(ReplayAudio());
                      },
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1976D2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          context.read<StoryPlayerBloc>().add(
                            NarrationFinished(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Challenge Mode (Question + Interactive Choices) ---
  Widget _buildChallengeContent(
    BuildContext context,
    StorySegment segment,
    Color textColor,
    bool isDark,
  ) {
    final challenge = segment.challenge as SingleChoiceChallenge;

    return Column(
      key: ValueKey(segment.id),
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "QUICK CHECK",
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black45,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Question
        Text(
          challenge.prompt,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
            height: 1.3,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 24),

        // Choices List
        ...challenge.choices.map((choice) {
          final isSelected = _selectedChoiceId == choice.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedChoiceId = choice.id;
                });
                // Auto-submit after small delay for visual feedback
                Future.delayed(const Duration(milliseconds: 300), () {
                  context.read<StoryPlayerBloc>().add(
                    SubmitAnswer(chosenAnswerId: choice.id),
                  );
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  // 🎨 Blue when selected, surface color when not
                  color: isSelected
                      ? const Color(0xFF1976D2) // Active Blue
                      : (isDark ? const Color(0xFF2A303C) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? Colors.white12 : Colors.black12),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF1976D2,
                            ).withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    // Choice Image/Icon
                    if (choice.imageUrl != null)
                      Container(
                        width: 44,
                        height: 44,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(choice.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    Expanded(
                      child: Text(
                        choice.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? Colors.white : textColor,
                        ),
                      ),
                    ),

                    // Checkmark indicator
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- Completion Screens ---

  Widget _buildLevelCompleted(
    BuildContext context,
    LevelCompleted state,
    bool isDark,
  ) {
    return _buildCompletionCard(
      context,
      title: "Congratulations!",
      // Shows the story title dynamically
      subtitle: "You have completed: ${state.storyTitle}",
      buttonText: "EMBARK ON THE NEXT JOURNEY",
      onPressed: () => context.go('/story-trails'),
      isDark: isDark,
      xpEarned: 500, // Or state.xpEarned
    );
  }

  Widget _buildStoryFinished(
    BuildContext context,
    StoryPlayerFinished state,
    bool isDark,
  ) {
    return _buildCompletionCard(
      context,
      title: "Congratulations!",
      // Shows the story title dynamically
      subtitle: "You have completed: ${state.storyTitle}",
      buttonText: "EMBARK ON THE NEXT JOURNEY",
      onPressed: () => context.go('/story-trails'),
      isDark: isDark,
      xpEarned: state.finalProgress.xpEarned,
    );
  }

  // ... (Previous imports and class definition remain the same) ...

  // Replace the old _buildCompletionCard with this new one
  Widget _buildCompletionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
    required bool isDark,
    required int xpEarned,
  }) {
    // --- 1. THEME-AWARE COLOR PALETTE ---

    // Background: Deep Space (Dark) vs Soft Mist (Light)
    final bgColor = isDark ? const Color(0xFF050810) : const Color(0xFFF0F4F8);

    // Card: Deep Navy (Dark) vs Pure White (Light)
    final cardColor = isDark ? const Color(0xFF0F1623) : Colors.white;

    // Text: White vs Dark Blue-Grey
    final textColor = isDark
        ? Colors.white
        : const Color(0xFF1A237E); // Deep Blue text for Light mode
    final subTextColor = isDark
        ? const Color(0xFF90A4AE)
        : const Color(0xFF546E7A);
    final dividerColor = isDark ? Colors.white12 : Colors.black12;

    // --- 2. UNIFIED EFFECTS (NEON LOOK FOR BOTH) ---
    final glowColor = const Color(0xFF64B5F6); // Bright Blue
    final accentCyan = const Color(0xFF80DEEA); // Cyan

    // Border: Visible in both modes
    final cardBorder = Border.all(
      color: glowColor.withValues(alpha: isDark ? 0.3 : 0.4),
      width: 1.5,
    );

    // Shadow: Colored Glow in BOTH modes (No black shadows)
    final cardShadow = BoxShadow(
      color: glowColor.withValues(
        alpha: isDark ? 0.15 : 0.25,
      ), // Stronger alpha in light mode to be visible
      blurRadius: 40,
      spreadRadius: 2,
      offset: const Offset(0, 0), // Centered glow
    );

    // Ambience Gradient (Background)
    final ambientGradient = RadialGradient(
      center: Alignment.center,
      radius: 1.0,
      colors: isDark
          ? [
              const Color(0xFF1A237E).withValues(alpha: 0.15),
              Colors.transparent,
            ]
          : [
              const Color(0xFF4FC3F7).withValues(alpha: 0.15),
              Colors.transparent,
            ], // Light Blue glow
    );

    // Text Styles
    final headerStyle = TextStyle(
      fontFamily: 'Georgia',
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: textColor,
      letterSpacing: 0.5,
      // Subtle text glow
      shadows: [
        Shadow(color: glowColor.withValues(alpha: 0.3), blurRadius: 15),
      ],
    );

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Ambience (Now visible in BOTH modes)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: ambientGradient),
            ),
          ),

          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(36),
                border: cardBorder, // Glowing border
                boxShadow: [cardShadow], // Glowing shadow
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- HEADER ---
                  Text(title, style: headerStyle, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 15,
                      color: subTextColor,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),
                  Divider(color: dividerColor, thickness: 1),
                  const SizedBox(height: 30),

                  // --- ICONS & STATS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        child: Column(
                          children: [
                            // Shared helper for Gradient Icons
                            _buildGradientIcon(
                              Icons.verified_user_outlined,
                              accentCyan,
                              glowColor,
                              true, // Always force "glow" effect on icons
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Story Mastered",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Right Column
                      Expanded(
                        child: Column(
                          children: [
                            _buildGradientIcon(
                              Icons.auto_graph_rounded,
                              accentCyan,
                              glowColor,
                              true,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "New Lore Unlocked",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "+$xpEarned XP",
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  Divider(color: dividerColor, thickness: 1),
                  const SizedBox(height: 24),

                  // --- FOOTER QUOTE ---
                  Text(
                    "Every journey completed strengthens your command of language and expands your unique saga.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: subTextColor,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                      fontFamily: 'Georgia',
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- GRADIENT BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: [accentCyan, glowColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: onPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          buttonText.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            letterSpacing: 0.5,
                            color: Color(
                              0xFF0D1B2A,
                            ), // Dark text on bright button
                          ),
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

  // --- Helper for "Glowing" Icons ---
  Widget _buildGradientIcon(
    IconData icon,
    Color color1,
    Color color2,
    bool isDark,
  ) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color1, color2],
        ).createShader(bounds);
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // Only show the "back glow" in dark mode for that neon effect
          // In light mode, keep it clean.
          boxShadow: isDark
              ? [
                  BoxShadow(
                    color: color2.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              : [],
        ),
        child: Icon(
          icon,
          size: 56, // Size from image
          color: Colors.white, // Required for ShaderMask to work
        ),
      ),
    );
  }
}

// Helper for the bar chart bars

// --- 3. The Typewriter Widget (Helper) ---
class TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration typingSpeed;

  const TypewriterText({
    super.key,
    required this.text,
    required this.style,
    // Default to a safe reading speed (30ms per char)
    this.typingSpeed = const Duration(milliseconds: 30),
  });

  @override
  State<TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<TypewriterText> {
  String _displayedText = "";
  Timer? _timer;
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  @override
  void didUpdateWidget(TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _startTyping();
    }
  }

  void _startTyping() {
    _timer?.cancel();

    // FIX 1: Show first char immediately if possible
    if (widget.text.isEmpty) {
      _displayedText = "";
      _charIndex = 0;
      return;
    }

    _displayedText = widget.text.substring(0, 1);
    _charIndex = 1;

    _timer = Timer.periodic(widget.typingSpeed, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_charIndex < widget.text.length) {
        setState(() {
          _charIndex++;
          _displayedText = widget.text.substring(0, _charIndex);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIX 2: Align left to prevent text jumping while typing
    return Text(_displayedText, style: widget.style, textAlign: TextAlign.left);
  }
}
