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
    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(LoadUserProfile()),
      child: Scaffold(
        // Uses AppTheme.scaffoldBackgroundColor (Off-white or Dark Grey)
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
            // Minimalist Settings Icon (Theme Toggle logic usually lives here or in settings)
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              onPressed: () {
                // Navigate to settings
              },
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    // 1. Identity Header (Avatar + Name + Edit)
                    ProfileHeader(
                      identity: user.identity,
                      onEditPressed: () => _showEditSheet(context, user),
                    ),

                    const SizedBox(height: 24),

                    // 2. The Main Garden Card (Tree + Streak)
                    GardenShowcaseCard(growth: user.growth, habit: user.habit),

                    const SizedBox(height: 24),

                    // 3. Stats Row (Stories & Shorts)
                    ProfileStatsRow(stats: user.growth.stats),
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
        // We provide the SAME Bloc instance to the sheet so it can trigger updates
        return BlocProvider.value(
          value: context.read<ProfileBloc>(),
          child: EditProfileSheet(currentUser: user),
        );
      },
    );
  }
}
