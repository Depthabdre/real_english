import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/app/injection_container.dart';
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

// --- Main App Shell with Bottom Navigation ---
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
    return Scaffold(
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
      ShellRoute(
        builder: (context, state, child) => MainAppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const PlaceholderScreen(title: 'Home'),
          ),
          GoRoute(
            path: '/quizzes',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Quizzes'),
          ),
          GoRoute(
            path: '/feed',
            builder: (context, state) => const PlaceholderScreen(title: 'Feed'),
          ),
          GoRoute(
            path: '/practice',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Practice'),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Profile'),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final bool seenOnboarding = hasSeenOnboarding.value;
      final bool loggedIn = isAuthenticated.value;
      final String location = state.uri.toString();
      final bool isOnboarding = location == '/onboarding';
      final isAuthenticating =
          location.startsWith('/signin') ||
          location.startsWith('/signup') ||
          location.startsWith('/forgot-password') ||
          location.startsWith('/otppage') ||
          location.startsWith('/reset-password') ||
          location.startsWith('/password-reset-success');

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
