import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';

import '../../../../app/injection_container.dart';
import '../bloc/story_trails_list_bloc.dart';
import '../widgets/story_trail_card.dart'; // We can still reuse our card widget

class StoryTrailsListPage extends StatelessWidget {
  const StoryTrailsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider<StoryTrailsListBloc>(
        create: (context) =>
            sl<StoryTrailsListBloc>()..add(FetchStoryTrailsList()),
        child: BlocBuilder<StoryTrailsListBloc, StoryTrailsListState>(
          builder: (context, state) {
            // Use a Stack to place content on top of a background image
            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. BACKGROUND IMAGE
                Image.asset(
                  'assets/images/story_background.jpg', // TODO: Add a nice background image to your assets
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(
                    0.4,
                  ), // Darken the image for text readability
                  colorBlendMode: BlendMode.darken,
                ),

                // 2. MAIN CONTENT
                SafeArea(
                  child: switch (state) {
                    StoryTrailsListInitial() ||
                    StoryTrailsListLoading() => const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),

                    StoryTrailsListError(message: final msg) =>
                      _buildErrorState(context, msg),

                    StoryTrailsListLoaded(storyTrail: final story) =>
                      story == null
                          ? _buildAllLevelsCompleteView(
                              context,
                              state.currentLevel,
                            )
                          : _buildAdventureCard(context, story),

                    _ => const Center(child: Text('Something went wrong.')),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget to display the single, focused story adventure
  Widget _buildAdventureCard(BuildContext context, StoryTrail storyTrail) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Today's Adventure",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // We reuse the card widget we built before!
          StoryTrailCard(storyTrail: storyTrail),
        ],
      ),
    );
  }

  // Widget to display when all stories for the current level are complete
  Widget _buildAllLevelsCompleteView(BuildContext context, int currentLevel) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration_rounded, color: Colors.amber, size: 80),
          const SizedBox(height: 24),
          Text(
            "You're All Caught Up!",
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "You've completed all the adventures for Level $currentLevel. New stories are on their way. Great job!",
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper for showing an error
  Widget _buildErrorState(BuildContext context, String message) {
    // ... (This can be the same error widget as before, but adapted for a dark background)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () =>
                context.read<StoryTrailsListBloc>().add(FetchStoryTrailsList()),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
