import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/app/injection_container.dart';
import 'package:real_english/feature/StoryTrails/presentation/pages/story_trails_list_page.dart';
import 'package:real_english/feature/auth_onboarding/presentation/pages/forgot_password_page.dart';
import 'package:real_english/feature/auth_onboarding/presentation/pages/onboarding_page.dart';
import 'package:real_english/feature/auth_onboarding/presentation/pages/otp_page.dart';
import 'package:real_english/feature/auth_onboarding/presentation/pages/password_reset_success_page.dart';
import 'package:real_english/feature/auth_onboarding/presentation/pages/reset_password_page.dart';
import 'package:real_english/feature/auth_onboarding/presentation/pages/signin_page.dart';
import 'package:real_english/feature/auth_onboarding/presentation/pages/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Placeholder Screen for unbuilt features ---
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          'Screen: $title',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212), // dark gray-black background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Image(
              image: AssetImage('assets/images/RealIcon2.png'),
              width: 120,
              height: 120,
            ),
            SizedBox(height: 25),

            // App Name
            Text(
              'Real English',
              style: TextStyle(
                color: Colors.white, // white text for contrast
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.3,
              ),
            ),

            SizedBox(height: 18),

            // Subtle progress indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Main App Shell with Bottom Navigation and Custom Back Logic ---
class MainAppShell extends StatelessWidget {
  final Widget child;
  const MainAppShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/quizzes')) return 1;
    if (location.startsWith('/feed')) return 2;
    if (location.startsWith('/practice')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/quizzes');
        break;
      case 2:
        context.go('/feed');
        break;
      case 3:
        context.go('/practice');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    // Check if the current page is one of the main pages that should redirect to home on back press
    final isRedirectablePage =
        location.startsWith('/quizzes') ||
        location.startsWith('/feed') ||
        location.startsWith('/practice') ||
        location.startsWith('/profile');

    return PopScope<bool>(
      canPop: !isRedirectablePage, // block back navigation for certain pages
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && isRedirectablePage) {
          // Pop was blocked, so redirect to home
          context.go('/home');
        } else if (didPop) {
          // Pop succeeded, you can handle result if needed
          print('Page popped successfully with result: $result');
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.quiz_outlined),
              activeIcon: Icon(Icons.quiz),
              label: 'Quizzes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library_outlined),
              activeIcon: Icon(Icons.video_library),
              label: 'Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mic_none_outlined),
              activeIcon: Icon(Icons.mic),
              label: 'Practice',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// --- GoRouter Configuration ---
class AppRouter {
  final ValueNotifier<bool> hasSeenOnboarding = ValueNotifier(false);
  final ValueNotifier<bool> isAuthenticated = ValueNotifier(false);

  AppRouter() {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = sl<SharedPreferences>();
    hasSeenOnboarding.value = prefs.getBool('hasSeenOnboarding') ?? false;
  }

  /// Updates both persistent storage and the in-memory state notifier.
  Future<void> setOnboardingComplete() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('hasSeenOnboarding', true);
    hasSeenOnboarding.value = true;
  }

  late final GoRouter router = GoRouter(
    refreshListenable: Listenable.merge([hasSeenOnboarding, isAuthenticated]),
    initialLocation: '/home',
    routes: [
      // --- Authentication and Onboarding Routes ---
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(path: '/signin', builder: (context, state) => const SignInPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/otppage',
        builder: (context, state) =>
            OtpPage(email: state.extra as String? ?? 'No email'),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) =>
            ResetPasswordPage(resetToken: state.extra as String? ?? ''),
      ),
      GoRoute(
        path: '/password-reset-success',
        builder: (context, state) => const PasswordResetSuccessPage(),
      ),

      // --- Main Application Routes ---
      GoRoute(
        path: '/home',
        builder: (context, state) =>
            const MainAppShell(child: PlaceholderScreen(title: 'Home')),
      ),
      GoRoute(
        path: '/quizzes',
        builder: (context, state) =>
            const MainAppShell(child: StoryTrailsListPage()),
      ),
      GoRoute(
        path: '/feed',
        builder: (context, state) =>
            const MainAppShell(child: PlaceholderScreen(title: 'Feed')),
      ),
      GoRoute(
        path: '/practice',
        builder: (context, state) =>
            const MainAppShell(child: PlaceholderScreen(title: 'Practice')),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) =>
            const MainAppShell(child: PlaceholderScreen(title: 'Profile')),
      ),
    ],
    redirect: (context, state) {
      final bool seenOnboarding = hasSeenOnboarding.value;
      final bool loggedIn = isAuthenticated.value;
      final String location = state.uri.toString();
      final bool isOnboarding = location == '/onboarding';
      const authRoutes = {
        '/signin',
        '/signup',
        '/forgot-password',
        '/otppage',
        '/reset-password',
        '/password-reset-success',
      };

      final isAuthenticating = authRoutes.contains(location);

      if (!seenOnboarding && !isOnboarding) return '/onboarding';
      if (seenOnboarding && isOnboarding) return '/signin';
      if (!loggedIn && !isAuthenticating && !isOnboarding) return '/signin';
      if (loggedIn && (isAuthenticating || isOnboarding)) return '/home';

      return null;
    },
    errorBuilder: (context, state) =>
        const PlaceholderScreen(title: '404 - Not Found'),
  );
}
