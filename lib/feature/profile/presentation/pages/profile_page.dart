import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/feature/profile/presentation/widgets/profile_skeleton_loader.dart';

import '../../../../app/injection_container.dart';
import '../../../../app/theme_cubit.dart';
import '../../../../feature/auth_onboarding/presentation/bloc/auth_bloc.dart';

import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/garden_showcase_card.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect theme for toggle logic
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/signin'); // Corrected route to /signin
        }
      },
      child: BlocProvider(
        create: (context) => sl<ProfileBloc>()..add(LoadUserProfile()),
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // Custom Slivers for a "Natural Scroll" feel
          body: SafeArea(
            child: BlocBuilder<ProfileBloc, ProfileState>(
              builder: (context, state) {
                if (state is ProfileLoading) {
                  return ProfileSkeletonLoader();
                }

                if (state is ProfileError) {
                  return Center(child: Text(state.message));
                }

                if (state is ProfileLoaded) {
                  final user = state.user;

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // 1. Custom App Bar with Theme Toggle
                      SliverAppBar(
                        floating: true,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        title: Text(
                          "My Sanctuary",
                          style: TextStyle(
                            fontFamily: 'Fredoka', // Playful Font
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        actions: [
                          _buildThemeToggle(context, isDark),
                          const SizedBox(width: 16),
                        ],
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),

                              // 2. Identity Header
                              ProfileHeader(
                                identity: user.identity,
                                onEditPressed: () =>
                                    _showEditSheet(context, user),
                              ),

                              const SizedBox(height: 32),

                              // 3. The Garden (Main Hero)
                              Text(
                                "Your Growth",
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              GardenShowcaseCard(
                                growth: user.growth,
                                habit: user.habit,
                              ),

                              const SizedBox(height: 32),

                              // 4. Stats (Nutrients)
                              Text(
                                "Nutrients Absorbed",
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ProfileStatsRow(stats: user.growth.stats),

                              const SizedBox(height: 48),

                              // 5. Logout
                              _buildLogoutButton(context),

                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            key: ValueKey(isDark),
            color: isDark ? Colors.amber : Colors.indigo,
            size: 24,
          ),
        ),
        onPressed: () {
          context.read<ThemeCubit>().toggleTheme();
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: TextButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        icon: Icon(
          Icons.logout_rounded,
          size: 20,
          color: theme.colorScheme.error,
        ),
        label: Text(
          "Take a Break (Log Out)",
          style: TextStyle(
            fontFamily: 'Nunito',
            color: theme.colorScheme.error,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: theme.colorScheme.error.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Leaving so soon?",
          style: TextStyle(fontFamily: 'Fredoka'),
        ),
        content: const Text(
          "Your garden will pause growing until you return.",
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              "Stay",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(SignOutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Log Out",
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... inside ProfilePage class ...

  void _showEditSheet(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,

      // --- FIX 1: SIT ON TOP OF NAV BAR ---
      useRootNavigator:
          true, // This ensures it covers the Bottom Navigation Bar
      // --- FIX 2: FULL HEIGHT ---
      isScrollControlled: true, // Allows the sheet to expand fully

      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) {
        return Padding(
          // Ensure it respects the keyboard (viewInsets)
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: BlocProvider.value(
            value: context.read<ProfileBloc>(),
            child: EditProfileSheet(currentUser: user),
          ),
        );
      },
    );
  }
}
