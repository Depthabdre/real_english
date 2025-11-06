import 'package:flutter/material.dart';
import 'package:real_english/app/app_router.dart';

// Import the service locator to access dependencies like SharedPreferences
import '../../../../app/injection_container.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // The content for the onboarding screens remains the same.
  final List<Widget> _onboardingScreens = [
    const _OnboardingContent(
      icon: Icons.school_rounded,
      title: "Welcome to Ethio English!",
      description:
          "Your fun and personal journey to mastering English starts here.",
    ),
    const _OnboardingContent(
      icon: Icons.park_rounded, // A friendly, natural icon
      title: "Learn Without Realizing It",
      description:
          "Participate in daily stories and challenges that feel like a game. Master English in context, just like you learned your first language.",
    ),
    const _OnboardingContent(
      icon: Icons.mic_rounded,
      title: "Perfect Your Pronunciation",
      description:
          "Use our AI tools to listen, record your voice, and get instant feedback on your accent.",
    ),
  ];

  /// Finishes the onboarding flow.
  void _finishOnboarding() async {
    // Get the singleton instance of our AppRouter from the service locator
    final appRouter = sl<AppRouter>();

    // Call the method that handles updating both storage and the live state notifier.
    // This will automatically trigger the router's redirect logic.
    await appRouter.setOnboardingComplete();
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

  /// Builds the bottom controls (Skip/Next buttons and page indicators).
  Widget _buildBottomControls() {
    final isLastPage = _currentPage == _onboardingScreens.length - 1;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Show a placeholder on the last page to keep the indicators centered
          isLastPage
              ? const SizedBox(width: 80)
              : _buildTextButton("Skip", _finishOnboarding),

          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingScreens.length,
              (index) => _buildPageIndicator(index == _currentPage),
            ),
          ),

          // Show "Get Started" on the last page, otherwise "Next"
          isLastPage
              ? ElevatedButton(
                  onPressed: _finishOnboarding,
                  // UPDATED: Style is now consistent with other auth pages.
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

/// A reusable widget for the content displayed on each onboarding screen.
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
