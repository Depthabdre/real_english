import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart'; // Just Audio ^0.9.36
import '../../../../app/injection_container.dart';
import '../../../../app/app_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation Controller for the Typewriter Effect
  late AnimationController _textAnimController;

  int _currentPage = 0;
  bool _isContentFinished = false; // Only true when LAST audio finishes
  bool _isMuted = false;

  // We ignore all audio events while this is true.
  bool _isSwitchingPage = false;

  Timer? _loadingSafetyTimer;
  Timer? _autoAdvanceTimer;

  // ---------------------------------------------------------
  // 1. DATA
  // ---------------------------------------------------------
  final List<OnboardingItem> _items = [
    OnboardingItem(
      imagePath: 'assets/onboarding/stress_study.png',
      audioPath: 'assets/audio/intro_struggle.wav',
      title: "Still\nStruggling?",
      description:
          "You studied for years... yet the words get stuck. It is not your fault. The process asked too much from your mind... and too little from your heart.",
      bgColor: const Color(0xFFF5F7FA),
      accentColor: const Color(0xFF546E7A),
    ),
    OnboardingItem(
      imagePath: 'assets/onboarding/child_listen.png',
      audioPath: 'assets/audio/natural_miracle.wav',
      title: "You Learned\nOnce Naturally.",
      description:
          "Remember how you learned Amharic? No rules. No exams. Just listening... and understanding. That power... is still sleeping inside you.",
      bgColor: const Color(0xFFF3E5F5),
      accentColor: const Color(0xFF6C63FF),
    ),
    OnboardingItem(
      imagePath: 'assets/onboarding/phone_laugh.png',
      audioPath: 'assets/audio/no_pressure.wav',
      title: "No Pressure\nHere.",
      description:
          "Stop fighting the language. There is nothing to prove here. Just watch... listen... and let the understanding settle in.",
      bgColor: const Color(0xFFFFF3E0),
      accentColor: const Color(0xFFFF6584),
    ),
    OnboardingItem(
      imagePath: 'assets/onboarding/flower_bloom.png',
      audioPath: 'assets/audio/confidence_bloom.wav',
      title: "Confidence\nBuilds Quietly.",
      description:
          "Mistakes will pass. Fear will fade. This is not about grades... it is about finding your voice.",
      bgColor: const Color(0xFFE8F5E9),
      accentColor: const Color(0xFF4CAF50),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // Init Animation Controller
    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // 2. ROBUST LISTENER LOGIC
    _audioPlayer.playerStateStream.listen((playerState) {
      // LOCK CHECK: If we are switching pages, IGNORE everything.
      if (_isSwitchingPage) return;

      if (playerState.processingState == ProcessingState.completed) {
        // DOUBLE CHECK: Ensure we actually played some audio (>100ms)
        // This stops "ghost" completions from previous tracks.
        if (_audioPlayer.position.inMilliseconds > 100) {
          _handleAudioComplete();
        }
      }
    });

    // Start First Slide
    _playPageContent(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _textAnimController.dispose();
    _loadingSafetyTimer?.cancel();
    _autoAdvanceTimer?.cancel();
    super.dispose();
  }

  // --- LOGIC: Handle Audio End ---
  void _handleAudioComplete() {
    if (!mounted || _isSwitchingPage) return;

    // Ensure text finishes visually
    _textAnimController.value = 1.0;

    if (_currentPage < _items.length - 1) {
      // NOT LAST PAGE -> Wait 1s then Go Next
      // We lock immediately to prevent repeated triggers
      _isSwitchingPage = true;

      _autoAdvanceTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) _goToNextPage();
      });
    } else {
      // LAST PAGE -> Unlock Button
      setState(() {
        _isContentFinished = true;
      });
    }
  }

  void _goToNextPage() async {
    int nextIndex = _currentPage + 1;

    // Update Index UI
    setState(() {
      _currentPage = nextIndex;
    });

    // Slide Animation
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );

    // Play Content
    await _playPageContent(nextIndex);
  }

  // --- LOGIC: Play Content (With Locks) ---
  Future<void> _playPageContent(int index) async {
    _loadingSafetyTimer?.cancel();
    _autoAdvanceTimer?.cancel();

    // 1. LOCK: Prevent listener from firing during setup
    _isSwitchingPage = true;

    // 2. Reset Animation UI
    _textAnimController.stop();
    _textAnimController.reset();

    // Safety: If loading fails/hangs for 6s, simulate completion
    _loadingSafetyTimer = Timer(const Duration(seconds: 6), () {
      debugPrint("Audio load timeout - switching to simulation");
      _runSimulatedPlayback();
    });

    if (!_isMuted) {
      try {
        await _audioPlayer.stop();

        // 3. Load Asset
        final duration = await _audioPlayer.setAsset(_items[index].audioPath);

        // Load Success -> Cancel Safety
        _loadingSafetyTimer?.cancel();

        // 4. Sync Animation Duration
        final exactDuration = duration ?? const Duration(seconds: 5);
        _textAnimController.duration = exactDuration;

        // 5. UNLOCK & PLAY
        // We are ready to play, so we enable the listener again
        _isSwitchingPage = false;

        _audioPlayer.play();
        _textAnimController.forward();
      } catch (e) {
        debugPrint("Audio Error: $e");
        _loadingSafetyTimer?.cancel();
        _runSimulatedPlayback();
      }
    } else {
      _loadingSafetyTimer?.cancel();
      _runSimulatedPlayback();
    }
  }

  void _runSimulatedPlayback() {
    // Used for Mute Mode or Error Fallback
    _isSwitchingPage = false; // Unlock so timer works
    _textAnimController.duration = const Duration(seconds: 5);
    _textAnimController.forward();

    // Manually trigger "Complete" after 6 seconds
    _autoAdvanceTimer = Timer(const Duration(seconds: 6), _handleAudioComplete);
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      _audioPlayer.stop();
      _runSimulatedPlayback();
    } else {
      // Cancel simulation and restart real audio
      _autoAdvanceTimer?.cancel();
      _playPageContent(_currentPage);
    }
  }

  void _finishOnboarding() async {
    _audioPlayer.stop();
    final appRouter = sl<AppRouter>();
    await appRouter.setOnboardingComplete();
    if (mounted) {
      context.go('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeItem = _items[_currentPage];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        color: activeItem.bgColor,
        child: Stack(
          children: [
            Column(
              children: [
                // --- TOP: Immersive Image (55%) ---
                Expanded(
                  flex: 55,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (_, index) {
                      return _ImmersiveImage(item: _items[index]);
                    },
                  ),
                ),

                // --- BOTTOM: Text & Controls (45%) ---
                Expanded(
                  flex: 45,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Text Content
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            // KEY FIX: ValueKey ensures the widget destroys and rebuilds
                            // on every page turn, guaranteeing the typing effect resets.
                            child: _TypewriterTextContent(
                              key: ValueKey(_currentPage),
                              item: activeItem,
                              controller: _textAnimController,
                            ),
                          ),
                        ),

                        // Bottom Controls
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 30),
                          child: _buildBottomControls(activeItem.accentColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // --- MUTE BUTTON ---
            Positioned(
              top: 50,
              right: 20,
              child: IconButton(
                onPressed: _toggleMute,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(8),
                ),
                icon: Icon(
                  _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(Color accentColor) {
    final isLastPage = _currentPage == _items.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // SKIP (Hidden)
        const SizedBox(width: 60),

        // INDICATORS
        Row(
          children: List.generate(
            _items.length,
            (index) => _buildPageIndicator(index == _currentPage, accentColor),
          ),
        ),

        // ACTION BUTTON
        if (isLastPage)
          IgnorePointer(
            ignoring: !_isContentFinished,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isContentFinished ? 1.0 : 0.0,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: ElevatedButton(
                      onPressed: _finishOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "Start Living",
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          )
        else
          // Loading Indicator (Pulsing)
          Container(
            width: 55,
            height: 55,
            alignment: Alignment.center,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: accentColor.withOpacity(0.5),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPageIndicator(bool isActive, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ---------------------------------------------------------
// REUSABLE WIDGETS
// ---------------------------------------------------------
class _TypewriterTextContent extends StatelessWidget {
  final OnboardingItem item;
  final AnimationController controller;

  const _TypewriterTextContent({
    super.key, // Essential for rebuilding
    required this.item,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka',
            color: const Color(0xFF2D3142),
            fontSize: 32,
            height: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final int textLength = item.description.length;
            final int currentLength = (controller.value * textLength).toInt();
            final int safeLength = currentLength > textLength
                ? textLength
                : currentLength;
            final String displayedText = item.description.substring(
              0,
              safeLength,
            );

            return Text(
              displayedText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                color: const Color(0xFF546E7A),
                fontSize: 18,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ImmersiveImage extends StatelessWidget {
  final OnboardingItem item;
  const _ImmersiveImage({required this.item});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(item.imagePath, fit: BoxFit.cover),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String imagePath;
  final String audioPath;
  final String title;
  final String description;
  final Color bgColor;
  final Color accentColor;

  OnboardingItem({
    required this.imagePath,
    required this.audioPath,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.accentColor,
  });
}
