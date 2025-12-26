import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
          // Redirect to Login on success
          context.go('login');
        }
      },
      child: BlocProvider(
        create: (context) => sl<ProfileBloc>()..add(LoadUserProfile()),
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              "My Journey",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Theme Toggle
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).shadowColor.withValues(alpha: 0.2),
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? Colors.amber : Colors.indigo,
                    size: 20,
                  ),
                  onPressed: () {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
              ),
            ],
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }

              if (state is ProfileError) {
                return Center(child: Text(state.message));
              }

              if (state is ProfileLoaded) {
                final user = state.user;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      // 1. Header
                      ProfileHeader(
                        identity: user.identity,
                        onEditPressed: () => _showEditSheet(context, user),
                      ),

                      const SizedBox(height: 30),

                      // 2. Garden Card
                      GardenShowcaseCard(
                        growth: user.growth,
                        habit: user.habit,
                      ),

                      const SizedBox(height: 30),

                      // 3. Stats
                      ProfileStatsRow(stats: user.growth.stats),

                      const SizedBox(height: 40),

                      // 4. Logout Button
                      _buildLogoutButton(context),

                      const SizedBox(height: 50),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  /// 🌟 Consistent, Primary-Themed Logout Button
  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: OutlinedButton.icon(
        onPressed: () => _showLogoutConfirmation(context),
        icon: Icon(Icons.logout_rounded, size: 22, color: theme.primaryColor),
        label: Text(
          "Log Out",
          style: TextStyle(
            color: theme.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          side: BorderSide(
            color: theme.primaryColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: theme.primaryColor.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  /// 🛑 Modern Confirmation Modal
  void _showLogoutConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: theme.cardColor,
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Circle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.waving_hand_rounded,
                  color: theme.primaryColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                "See you soon?",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Your garden will be waiting for you when you return.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white70 : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 28),

              // Buttons Row
              Row(
                children: [
                  // Cancel
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Confirm
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx); // Close dialog
                        context.read<AuthBloc>().add(SignOutRequested());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: EditProfileSheet(currentUser: user),
        );
      },
    );
  }
}
