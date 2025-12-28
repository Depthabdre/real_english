import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/feature/profile/presentation/pages/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:ui'; // Required for ImageFilter (Blur)
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
import '../feature/daily_immersion/presentation/pages/immersion_feed_page.dart';
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

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    // 2. Trigger Auth Check
    context.read<AuthBloc>().add(AppStarted());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color primaryColor = theme.primaryColor;
    // Subtitle color: slightly darker in light mode for readability
    final Color subtitleColor = isDark
        ? const Color(0xFFCFD8DC)
        : const Color(0xFF546E7A);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Center Content
            Center(
              child: FadeTransition(
                opacity: _opacityAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. App Icon (The Hero)
                      // Made larger (150) since we removed the title text
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              // Soft glow behind the icon
                              color: primaryColor.withValues(alpha: 0.25),
                              blurRadius: 40,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/icon/RealIcon2.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(
                        height: 30,
                      ), // Increased spacing for balance
                      // 2. The Vision (Subtitle Only)
                      // Clean, organic, and friendly
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Master English naturally.\nJust like a child.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Nunito', // Soft rounded font
                            color: subtitleColor,
                            fontSize: 18, // Slightly larger to stand out
                            fontWeight:
                                FontWeight.w600, // Semi-bold for emphasis
                            height: 1.5, // breathable line spacing
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Creative Loading Animation (Bottom)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(child: BouncingDotsLoader(color: primaryColor)),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// Bouncing Dots Loader (Unchanged)
// -----------------------------------------------------------
class BouncingDotsLoader extends StatefulWidget {
  final Color color;
  const BouncingDotsLoader({super.key, required this.color});

  @override
  State<BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 10,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              transform: Matrix4.translationValues(
                0,
                -_animations[index].value,
                0,
              ),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.8),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

// --- Main App Shell  ---

class MainAppShell extends StatelessWidget {
  final Widget child;
  const MainAppShell({super.key, required this.child});

  // 1. Index Logic
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/feed')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  // 2. Navigation Logic
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/story-trails');
        break;
      case 1:
        context.go('/feed');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Feature Colors
    final Color colorStories = theme.colorScheme.primary;
    final Color colorFeed = theme.colorScheme.secondary;
    final Color colorGrowth = isDark
        ? const Color(0xFF81C784)
        : const Color(0xFF4CAF50);

    final Color navBarColor = isDark
        ? const Color(0xFF252A30).withValues(alpha: 0.50)
        : Colors.white.withValues(alpha: 0.50);

    // Border Colors for the "Glass Edge" look
    final Color borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.6); // Stronger border for light mode

    final String location = GoRouterState.of(context).uri.toString();
    final int currentIndex = _calculateSelectedIndex(context);

    final isRootTab =
        location == '/story-trails' ||
        location == '/feed' ||
        location == '/profile';

    return PopScope<bool>(
      canPop: location == '/story-trails' ? true : !isRootTab,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (isRootTab && location != '/story-trails') {
          context.go('/story-trails');
        }
      },
      child: Scaffold(
        extendBody: true, // Crucial for transparency
        body: child,
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 60,
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            // OUTER CONTAINER (Shadows)
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            // CLIPPING (Round shape for blur)
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                // BLUR EFFECT: This creates the "Glass" look
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  // INNER CONTAINER (Color Tint & Border)
                  decoration: BoxDecoration(
                    color: navBarColor,
                    border: Border.all(color: borderColor, width: 1.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCustomNavItem(
                        context: context,
                        isSelected: currentIndex == 0,
                        index: 0,
                        label: "Stories",
                        icon: Icons.auto_stories_rounded,
                        activeColor: colorStories,
                      ),
                      _buildCustomNavItem(
                        context: context,
                        isSelected: currentIndex == 1,
                        index: 1,
                        label: "Shorts",
                        icon: Icons.smart_display_rounded,
                        activeColor: colorFeed,
                        isCenter: true,
                      ),
                      _buildCustomNavItem(
                        context: context,
                        isSelected: currentIndex == 2,
                        index: 2,
                        label: "Growth",
                        icon: Icons.spa_rounded,
                        activeColor: colorGrowth,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomNavItem({
    required BuildContext context,
    required bool isSelected,
    required int index,
    required String label,
    required IconData icon,
    required Color activeColor,
    bool isCenter = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inactiveColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return GestureDetector(
      onTap: () => _onItemTapped(index, context),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: isSelected ? 105 : 55,
        height: 40,
        decoration: isSelected
            ? BoxDecoration(
                // Using .withValues for the selection pill background
                color: activeColor.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isCenter ? 26 : 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    color: activeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- UPDATED AppRouter Configuration ---

class AppRouter {
  final AuthBloc authBloc;
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
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authBloc.stream),
      hasSeenOnboarding,
    ]),

    // Initial location checks Splash
    initialLocation: '/splash',

    routes: [
      // =================================================================
      // 1. PUBLIC ROUTES (No Navigation Bar)
      // =================================================================
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      // --- Auth Routes ---
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

      // --- Full Screen Player (Outside Shell) ---
      // We put this here so the Bottom Nav Bar HIDES when playing a story
      GoRoute(
        path: '/story-player/:trailId',
        builder: (context, state) {
          final trailId = state.pathParameters['trailId']!;
          return StoryPlayerPage(trailId: trailId);
        },
      ),

      // =================================================================
      // 2. SHELL ROUTE (Floating Bottom Navigation Bar)
      // =================================================================
      ShellRoute(
        // This builder wraps the child in your fancy MainAppShell
        builder: (context, state, child) {
          return MainAppShell(child: child);
        },
        routes: [
          // CORE FEATURE 1: STORIES (New Home)
          GoRoute(
            path: '/story-trails',
            builder: (context, state) => const StoryTrailsListPage(),
          ),

          // CORE FEATURE 2: FEED (Shorts)
          GoRoute(
            path: '/feed',
            builder: (context, state) => const ImmersionFeedPage(),
          ),

          // CORE FEATURE 3: PROFILE (Growth)
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),
    ],

    // =================================================================
    // 3. REDIRECT LOGIC
    // =================================================================
    redirect: (context, state) {
      final bool seenOnboarding = hasSeenOnboarding.value;
      final AuthState authState = authBloc.state;

      final String location = state.uri.toString();
      final bool isSplash = location == '/splash';
      final bool isOnboarding = location == '/onboarding';
      final bool isLoggingIn =
          location == '/signin' ||
          location == '/signup' ||
          location ==
              '/forgot-password'; // Don't redirect if resetting password

      // A. Handle Splash Screen
      if (isSplash) {
        if (authState is Authenticated) {
          return '/story-trails'; // SUCCESS: Go to Stories (New Home)
        }
        if (authState is Unauthenticated || authState is AuthError) {
          return seenOnboarding ? '/signin' : '/onboarding';
        }
        return null; // Wait
      }

      // B. Handle Authenticated User
      if (authState is Authenticated) {
        // If trying to access login/onboarding, send them to app
        if (isLoggingIn || isOnboarding) {
          return '/story-trails';
        }
      }

      // C. Handle Unauthenticated User
      if (authState is Unauthenticated || authState is AuthError) {
        // Allow access to auth pages, otherwise kick to login
        final isAuthPage =
            location.startsWith('/signin') ||
            location.startsWith('/signup') ||
            location.startsWith('/forgot-password') ||
            location.startsWith('/otppage') ||
            location.startsWith('/reset-password') ||
            location.startsWith('/password-reset-success');

        if (!isAuthPage && !isOnboarding) {
          return seenOnboarding ? '/signin' : '/onboarding';
        }
      }

      return null;
    },
    errorBuilder: (context, state) =>
        const PlaceholderScreen(title: '404 - Not Found'),
  );
}
