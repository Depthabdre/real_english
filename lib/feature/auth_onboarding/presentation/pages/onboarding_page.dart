import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/injection_container.dart';
import '../../../../app/app_router.dart'; // Ensure correct import path

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // ---------------------------------------------------------
  // 1. DATA: The 4-Step Narrative Arc
  // ---------------------------------------------------------
  final List<OnboardingItem> _items = [
    // SCREEN 1: THE PROBLEM (School Failed You)
    OnboardingItem(
      imagePath: 'assets/onboarding/stress_study.png',
      title: "Years in School.\nStill Can't Speak?",
      description:
          "You treated English like a textbook subject—memorizing rules to pass exams. But you can't 'study' fluency. You have to acquire it.",
      bgColor: const Color(0xFFF5F7FA), // Calm Light Grey
      accentColor: const Color(0xFF546E7A),
    ),

    // SCREEN 2: THE PROOF (Your Natural Ability) - **Updated with your text**
    OnboardingItem(
      imagePath: 'assets/onboarding/child_listen.png',
      title: "How Did You\nLearn Amharic?",
      description:
          "No one taught you grammar rules.\nNo exams. No stress.\nYou listened, understood, and spoke — naturally.",
      bgColor: const Color(0xFFF3E5F5), // Soft Lavender
      accentColor: const Color(0xFF6C63FF), // Primary Purple
    ),

    // SCREEN 3: THE METHOD (Immersion)
    OnboardingItem(
      imagePath: 'assets/onboarding/phone_laugh.png',
      title: "Don't Memorize.\nJust Live It.",
      description:
          "Immerse yourself in addictive stories and short videos. Your brain will spot the patterns and lock them in without you trying. It’s entertainment, not homework.",
      bgColor: const Color(0xFFFFF3E0), // Soft Peach
      accentColor: const Color(0xFFFF6584), // Secondary Pink/Red
    ),

    // SCREEN 4: THE RESULT (Confidence)
    OnboardingItem(
      imagePath: 'assets/onboarding/flower_bloom.png',
      title: "Confidence.\nNot Grades.",
      description:
          "Forget the fear of making mistakes. Track your growth, not your test scores. Build real-world speaking confidence and let your English bloom.",
      bgColor: const Color(0xFFE8F5E9), // Soft Mint
      accentColor: const Color(0xFF4CAF50), // Green
    ),
  ];
  // ---------------------------------------------------------
  // 2. LOGIC: Existing Navigation Logic Preserved
  // ---------------------------------------------------------
  void _finishOnboarding() async {
    final appRouter = sl<AppRouter>();
    await appRouter.setOnboardingComplete();
    if (mounted) {
      context.go('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Current Active Color Theme based on page index
    final activeItem = _items[_currentPage];

    return Scaffold(
      // Animated Background Color Transition
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        color: activeItem.bgColor,
        child: SafeArea(
          child: Column(
            children: [
              // --- TOP: The Content (Image + Text) ---
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (_, index) {
                    return _OnboardingContent(item: _items[index]);
                  },
                ),
              ),

              // --- BOTTOM: Controls (Indicators + Buttons) ---
              _buildBottomControls(activeItem.accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(Color accentColor) {
    final isLastPage = _currentPage == _items.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. SKIP BUTTON (Hidden on last page)
          if (!isLastPage)
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
            const SizedBox(width: 60), // Spacer to keep layout balanced
          // 2. INDICATORS (Animated Pills)
          Row(
            children: List.generate(
              _items.length,
              (index) =>
                  _buildPageIndicator(index == _currentPage, accentColor),
            ),
          ),

          // 3. NEXT / GET STARTED BUTTON
          if (isLastPage)
            // "Get Started" - High emphasis with Animation
            TweenAnimationBuilder<double>(
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
                      shadowColor: accentColor.withValues(alpha: 0.4),
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
            )
          else
            // "Next" - Simple Circle Arrow
            InkWell(
              onTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                );
              },
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      // Active indicator stretches like a pill
      width: isActive ? 28 : 8,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ---------------------------------------------------------
// 3. CONTENT WIDGET: Displays Image & Text
// ---------------------------------------------------------
class _OnboardingContent extends StatelessWidget {
  final OnboardingItem item;

  const _OnboardingContent({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          const Spacer(flex: 1), // Push content down slightly
          // --- IMAGE SECTION ---
          // We use flexible to adapt to different screen sizes
          Flexible(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: item.accentColor.withValues(alpha: 0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Image.asset(item.imagePath, fit: BoxFit.contain),
            ),
          ),

          const SizedBox(height: 40),

          // --- TEXT SECTION ---
          Flexible(
            flex: 4,
            child: Column(
              children: [
                // Title (Fredoka Font)
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Fredoka', // Friendly Rounded Font
                    color: const Color(0xFF2D3142), // Dark Slate
                    fontSize: 32,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // Description (Nunito Font)
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito', // Readable Soft Font
                    color: const Color(0xFF607D8B), // Blue Grey
                    fontSize: 17,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// 4. MODEL CLASS
// ---------------------------------------------------------
class OnboardingItem {
  final String imagePath;
  final String title;
  final String description;
  final Color bgColor;
  final Color accentColor;

  OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.accentColor,
  });
}
