import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // 1. IMPORT GO_ROUTER
import 'package:real_english/app/app_router.dart';
import '../../../../app/injection_container.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Widget> _onboardingScreens = [
    const _OnboardingContent(
      icon: Icons.school_rounded,
      title: "Welcome to Ethio English!",
      description:
          "Your fun and personal journey to mastering English starts here.",
    ),
    const _OnboardingContent(
      icon: Icons.park_rounded,
      title: "Learn Without Realizing It",
      description:
          "Participate in daily stories and challenges that feel like a game. Master English in context.",
    ),
    const _OnboardingContent(
      icon: Icons.mic_rounded,
      title: "Perfect Your Pronunciation",
      description:
          "Use our AI tools to listen, record your voice, and get instant feedback on your accent.",
    ),
  ];

  /// --- UPDATED FUNCTION ---
  void _finishOnboarding() async {
    // 1. Get the AppRouter
    final appRouter = sl<AppRouter>();

    // 2. Update the state (Save to Prefs + Update Listener)
    await appRouter.setOnboardingComplete();

    // 3. EXPLICITLY NAVIGATE
    // Since the Redirect logic might allow you to stay on /onboarding
    // (to prevent loops), we must force the navigation here.
    if (mounted) {
      context.go('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingScreens.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (_, index) {
                  return _onboardingScreens[index];
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    final isLastPage = _currentPage == _onboardingScreens.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isLastPage
              ? const SizedBox(width: 80)
              : _buildTextButton("Skip", _finishOnboarding),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingScreens.length,
              (index) => _buildPageIndicator(index == _currentPage),
            ),
          ),

          isLastPage
              ? ElevatedButton(
                  onPressed: _finishOnboarding,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text("Get Started"),
                )
              : _buildTextButton("Next", () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _OnboardingContent({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 40),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}
