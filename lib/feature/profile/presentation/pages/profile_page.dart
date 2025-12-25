import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/injection_container.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/garden_showcase_card.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/edit_profile_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Helper to detect current theme mode for the toggle button UI
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
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
            // Theme Toggle Button
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
                  // TODO: Connect this to your AppTheme Logic
                  // e.g. context.read<ThemeCubit>().toggleTheme();
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
                    // 1. Identity Header
                    ProfileHeader(
                      identity: user.identity,
                      onEditPressed: () => _showEditSheet(context, user),
                    ),

                    const SizedBox(height: 30),

                    // 2. The Main Garden Showcase
                    GardenShowcaseCard(growth: user.growth, habit: user.habit),

                    const SizedBox(height: 30),

                    // 3. Stats Row
                    ProfileStatsRow(stats: user.growth.stats),

                    const SizedBox(height: 50),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
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
