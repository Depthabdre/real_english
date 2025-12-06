import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/injection_container.dart';
import '../../feature/StoryTrails/presentation/pages/story_player_page.dart';
import '../../feature/StoryTrails/presentation/pages/story_trails_list_page.dart';
// Import your Auth Bloc
import '../../feature/auth_onboarding/presentation/bloc/auth_bloc.dart';
// Import your pages
import '../../feature/auth_onboarding/presentation/pages/forgot_password_page.dart';
import '../../feature/auth_onboarding/presentation/pages/onboarding_page.dart';
import '../../feature/auth_onboarding/presentation/pages/otp_page.dart';
import '../../feature/auth_onboarding/presentation/pages/password_reset_success_page.dart';
import '../../feature/auth_onboarding/presentation/pages/reset_password_page.dart';
import '../../feature/auth_onboarding/presentation/pages/signin_page.dart';
import '../../feature/auth_onboarding/presentation/pages/signup_page.dart';
import '../core/routes/go_router_refresh_stream.dart'; // Import the helper file created above

// --- Placeholder Screen (UNCHANGED) ---
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

// --- UPDATED SPLASH SCREEN (New UI & Bloc Logic) ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the Auth Check (GetMe) when screen loads
    context.read<AuthBloc>().add(AppStarted());
  }

  @override
  Widget build(BuildContext context) {
    // Access theme data for dynamic coloring
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // 1. App Icon
              Image.asset('assets/icon/RealIcon2.png', width: 100, height: 100),

              const SizedBox(height: 30),

              // 2. App Name
              Text(
                'RealEnglish',
                style: theme.textTheme.headlineMedium?.copyWith(
                  // Use primary color or white based on theme
                  color: isDark ? Colors.white : theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // 3. Subtitle
              Text(
                'Learn English Naturally. Grow Your World.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? const Color(0xFFB0BEC5)
                      : const Color(0xFF616161),
                  fontSize: 14,
                ),
              ),

              const Spacer(flex: 1),

              // 4. Linear Progress Indicator
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        minHeight: 12,
                        backgroundColor: isDark
                            ? const Color(0xFF2C2C2C)
                            : const Color(0xFFE0E0E0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Loading...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Main App Shell (UNCHANGED) ---
class MainAppShell extends StatelessWidget {
  final Widget child;
  const MainAppShell({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/story-trails')) return 1;
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
        context.go('/story-trails');
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
    final isRedirectablePage =
        location.startsWith('/story-trails') ||
        location.startsWith('/feed') ||
        location.startsWith('/practice') ||
        location.startsWith('/profile');

    return PopScope<bool>(
      canPop: !isRedirectablePage,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && isRedirectablePage) {
          context.go('/home');
        } else if (didPop) {
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
              label: 'story-trails',
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

// --- UPDATED AppRouter Configuration ---
class AppRouter {
  final AuthBloc authBloc; // 1. Inject AuthBloc
  final ValueNotifier<bool> hasSeenOnboarding = ValueNotifier(false);

  AppRouter(this.authBloc) {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = sl<SharedPreferences>();
    hasSeenOnboarding.value = prefs.getBool('hasSeenOnboarding') ?? false;
  }

  Future<void> setOnboardingComplete() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('hasSeenOnboarding', true);
    hasSeenOnboarding.value = true;
  }

  late final GoRouter router = GoRouter(
    // 2. Listen to Bloc Stream + Onboarding
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authBloc.stream),
      hasSeenOnboarding,
    ]),

    // 3. Initial location is always Splash to perform the check
    initialLocation: '/splash',

    routes: [
      // --- Authentication and Onboarding Routes ---
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
        path: '/story-trails',
        builder: (context, state) {
          return const MainAppShell(child: StoryTrailsListPage());
        },
        routes: [
          GoRoute(
            path: 'player/:trailId',
            builder: (context, state) {
              final trailId = state.pathParameters['trailId']!;
              return StoryPlayerPage(trailId: trailId);
            },
          ),
        ],
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

    // 4. Redirect Logic using Bloc State
    redirect: (context, state) {
      final bool seenOnboarding = hasSeenOnboarding.value;
      final AuthState authState = authBloc.state; // Get current Bloc state

      final String location = state.uri.toString();
      final bool isSplash = location == '/splash';
      final bool isOnboarding = location == '/onboarding';
      final bool isLoggingIn = location == '/signin' || location == '/signup';

      // A. Handle Splash Screen (Wait for Bloc result)
      if (isSplash) {
        if (authState is Authenticated) {
          return '/home'; // Success -> Home
        }
        if (authState is Unauthenticated || authState is AuthError) {
          return seenOnboarding ? '/signin' : '/onboarding'; // Fail -> Login
        }
        return null; // Still Loading -> Stay on Splash
      }

      // B. Handle Authenticated User (Prevent going back to login)
      if (authState is Authenticated) {
        if (isLoggingIn || isOnboarding) {
          return '/home';
        }
      }

      // C. Handle Unauthenticated User (Protect app routes)
      if (authState is Unauthenticated || authState is AuthError) {
        if (!isLoggingIn && !isOnboarding) {
          return seenOnboarding ? '/signin' : '/onboarding';
        }
      }

      return null;
    },
    errorBuilder: (context, state) =>
        const PlaceholderScreen(title: '404 - Not Found'),
  );
}
