import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// --- Placeholder Screen (To be replaced with actual feature pages) ---
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
  late final GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      // --- Authentication Routes (No Shell) ---
      GoRoute(
        path: '/signin',
        builder: (context, state) => const PlaceholderScreen(title: 'Sign In'),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const PlaceholderScreen(title: 'Sign Up'),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) =>
            const PlaceholderScreen(title: 'Forgot Password'),
      ),

      // --- Main App Routes (With Shell) ---
      ShellRoute(
        builder: (context, state, child) {
          return MainAppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Home & Recommendations'),
          ),
          GoRoute(
            path: '/quizzes',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Quizzes'),
            routes: [
              GoRoute(
                path: ':id', // e.g., /quizzes/grammar101
                builder: (context, state) => PlaceholderScreen(
                  title: 'Quiz: ${state.pathParameters['id']}',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/feed',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Shorts Feed'),
          ),
          GoRoute(
            path: '/practice',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'Speaking Practice'),
            routes: [
              GoRoute(
                path: 'pronunciation',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Pronunciation Support'),
              ),
              GoRoute(
                path: 'peer-to-peer',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Peer-to-Peer Session'),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) =>
                const PlaceholderScreen(title: 'User Profile'),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) =>
        const PlaceholderScreen(title: '404 - Not Found'),
  );
}
