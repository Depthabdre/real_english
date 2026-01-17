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
    Future.delayed(const Duration(seconds: 7), () {
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
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () {
              // Forces navigation back to the Story Trail Home
              context.pop();
            },
          ),
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
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
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
    return _buildOrganicCompletionCard(
      context,
      title: "Chapter Complete",
      subtitle: "You have finished: ${state.storyTitle}",
      buttonText: "Continue Journey",
      onPressed: () => context.go('/story-trails'),
      isDark: isDark,
      xpEarned: 500, // Fixed XP for level up, or pass from state if available
    );
  }

  Widget _buildStoryFinished(
    BuildContext context,
    StoryPlayerFinished state,
    bool isDark,
  ) {
    return _buildOrganicCompletionCard(
      context,
      title: "Story Finished",
      subtitle: "You have finished: ${state.storyTitle}",
      buttonText: "Return to Path",
      onPressed: () => context.go('/story-trails'),
      isDark: isDark,
      xpEarned: state.finalProgress.xpEarned,
    );
  }

  // ... (Previous imports and class definition remain the same) ...

  Widget _buildOrganicCompletionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback
    onPressed, // We will ignore this and force context.go below
    required bool isDark,
    required int xpEarned,
  }) {
    final theme = Theme.of(context);

    // 1. Natural Palette

    final cardColor = isDark ? const Color(0xFF0F1623) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);
    final primaryColor = theme.colorScheme.primary;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(32),

            // Soft Border (Consistent with Trail Home)
            border: isDark
                ? Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  )
                : Border.all(
                    color: Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),

            // Soft "Sunlight" Shadow
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon Circle (Golden Glow)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  // Changed from Gold to a "Natural Growth" Green/Teal mix
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  // Changed from Star to Flower (Represents organic growth)
                  Icons.local_florist_rounded,
                  color: Color(0xFF43A047), // Vibrant Leaf Green
                  size: 50,
                ),
              ),

              const SizedBox(height: 32),

              // 2. Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 12),

              // 3. Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: textColor.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // 4. XP Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.spa_rounded, size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      "+$xpEarned Growth",
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 5. The Philosophy Quote (Motivation)
              // "Realistic but inspiring"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "\"A child doesn't study to speak; they simply live. Today, you lived a little more in English.\"",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: textColor.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 6. Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // RESET: Go back to the main list and clear history
                    context.go('/story-trails');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shadowColor: primaryColor.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper for "Glowing" Icons ---
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
