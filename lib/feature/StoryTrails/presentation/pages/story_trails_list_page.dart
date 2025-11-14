import 'dart:ui'; // Needed for ImageFilter.blur
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import '../../../../app/injection_container.dart';
import '../bloc/story_trails_list_bloc.dart';

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
            // Main stack with the new storybook background
            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Background Image
                Image.asset(
                  // IMPORTANT: Make sure this path is correct in your project
                  'assets/images/adventure_background4.png',
                  fit: BoxFit.cover,
                ),
                SafeArea(
                  child: switch (state) {
                    StoryTrailsListInitial() ||
                    StoryTrailsListLoading() => _buildLoadingState(),

                    StoryTrailsListError(message: final msg) =>
                      _buildErrorState(context, msg),

                    StoryTrailsListLoaded(storyTrail: final story) =>
                      story == null
                          ? _buildAllLevelsCompleteView(
                              context,
                              state.currentLevel,
                            )
                          : _buildAdventureView(context, story),

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

  /// Builds the main adventure screen, styled to match the provided UI image.
  Widget _buildAdventureView(BuildContext context, StoryTrail storyTrail) {
    // This is the custom font name you need to set up in pubspec.yaml
    const String storybookFont = 'YourStorybookFont';

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 2. "Today's Adventure" Title
              Text(
                "Today's Adventure",
                style: TextStyle(
                  fontFamily: storybookFont,
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black.withAlpha(102),
                      offset: const Offset(3, 3),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. Frosted Glass Card
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 32.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(15),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withAlpha(51),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 4. Circular Image - NOW LARGER
                        CircleAvatar(
                          radius: 60, // <-- Increased from 50
                          backgroundColor: Colors.white.withAlpha(204),
                          child: ClipOval(
                            child: SizedBox.fromSize(
                              size: const Size.fromRadius(
                                58,
                              ), // <-- Increased from 48
                              child: Image.network(
                                storyTrail.imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 5. Card Title
                        Text(
                          storyTrail.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: storybookFont,
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // 6. Card Description
                        Text(
                          storyTrail.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withAlpha(230),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 7. Start Adventure Button
                        _buildStartButton(context, storyTrail),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the button styled to match the UI.
  Widget _buildStartButton(BuildContext context, StoryTrail storyTrail) {
    return ElevatedButton(
      onPressed: () {
        context.go('/story-trails/player/${storyTrail.id}');
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6AABF3), // Specific blue from image
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Pill shape
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      child: const Text('Start Adventure'),
    );
  }

  // --- Helper widgets restyled for consistency ---

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
    );
  }

  // Helper widget for a consistent frosted glass container look
  Widget _buildOverlayContainer({required Widget child}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(128),
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllLevelsCompleteView(BuildContext context, int currentLevel) {
    return _buildOverlayContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.celebration_rounded, color: Colors.amber, size: 80),
          const SizedBox(height: 24),
          Text(
            "You're All Caught Up!",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            "You've completed all adventures for Level $currentLevel. New stories are coming soon!",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return _buildOverlayContainer(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
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
