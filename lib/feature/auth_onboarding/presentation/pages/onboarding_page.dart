import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart'; // 1. Using Just Audio
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

  // 1. Just Audio Player
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animation Controller for the Typewriter Effect
  late AnimationController _textAnimController;

  int _currentPage = 0;
  bool _isContentFinished = false; // Locks the buttons
  bool _isMuted = false;

  // Safety Timer (in case audio fails to load)
  Timer? _safetyTimer;

  // ---------------------------------------------------------
  // 2. DATA: Narrative + Audio (WAV)
  // ---------------------------------------------------------
  final List<OnboardingItem> _items = [
    OnboardingItem(
      imagePath: 'assets/onboarding/stress_study.png',
      // JUST AUDIO REQUIREMENT: Use full path starting with 'assets/'
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

    // Initialize Animation Controller (Duration set dynamically later)
    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // 2. Just Audio Completion Listener
    // We listen to the state stream to know when it finishes
    _audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        _finishContent();
      }
    });

    // Start First Slide
    _playPageContent(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose(); // Dispose Just Audio player
    _textAnimController.dispose();
    _safetyTimer?.cancel();
    super.dispose();
  }

  void _finishContent() {
    if (mounted && !_isContentFinished) {
      setState(() {
        _isContentFinished = true;
        _textAnimController.value = 1.0; // Ensure text is fully shown
      });
    }
  }

  Future<void> _playPageContent(int index) async {
    // Reset State for new page
    setState(() {
      _isContentFinished = false;
      _textAnimController.reset();
    });
    _safetyTimer?.cancel();

    // Safety Net: Unlock buttons after 10s if audio crashes
    _safetyTimer = Timer(const Duration(seconds: 10), _finishContent);

    if (!_isMuted) {
      try {
        // Stop previous
        await _audioPlayer.stop();

        // 3. Just Audio Load & Sync
        // Load the asset
        final duration = await _audioPlayer.setAsset(_items[index].audioPath);

        // Update Animation Duration to match Audio
        // If duration is null (rare), default to 3s
        final safeDuration = duration ?? const Duration(seconds: 3);

        setState(() {
          _textAnimController.duration = safeDuration;
        });

        // Play and Animate
        _textAnimController.forward();
        _audioPlayer.play();
      } catch (e) {
        debugPrint("Audio Error: $e");
        _finishContent(); // Unlock on error
      }
    } else {
      // Muted logic: Simulate reading time
      _textAnimController.duration = const Duration(seconds: 4);
      _textAnimController.forward();
      Future.delayed(const Duration(seconds: 4), _finishContent);
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      _audioPlayer.stop();
      _finishContent(); // Unlock immediately if muted
    } else {
      _playPageContent(_currentPage); // Restart audio
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
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable swipe
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

                        // Text Content (Typewriter Effect)
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: _TypewriterTextContent(
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
        // SKIP (Hidden unless content finished & not last page)
        if (!isLastPage && _isContentFinished)
          TextButton(
            onPressed: _finishOnboarding,
            child: Text(
              "Skip",
              style: TextStyle(
                fontFamily: 'Nunito',
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          const SizedBox(width: 60),

        // INDICATORS
        Row(
          children: List.generate(
            _items.length,
            (index) => _buildPageIndicator(index == _currentPage, accentColor),
          ),
        ),

        // NEXT / START BUTTON (Disabled if audio playing)
        IgnorePointer(
          ignoring: !_isContentFinished,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isContentFinished ? 1.0 : 0.3,
            child: isLastPage
                ? ElevatedButton(
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
                  )
                : InkWell(
                    onTap: () {
                      int next = _currentPage + 1;
                      _pageController.animateToPage(
                        next,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                      );
                      _playPageContent(next); // Play next audio
                      setState(() {
                        _currentPage = next;
                      });
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
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
// TYPEWRITER TEXT WIDGET
// ---------------------------------------------------------
class _TypewriterTextContent extends StatelessWidget {
  final OnboardingItem item;
  final AnimationController controller;

  const _TypewriterTextContent({required this.item, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Title (Static)
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

        // Description (Animated Typewriter)
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final int textLength = item.description.length;
            final int currentLength = (controller.value * textLength).toInt();
            // Safety check
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

// ---------------------------------------------------------
// IMAGE WIDGET
// ---------------------------------------------------------
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
