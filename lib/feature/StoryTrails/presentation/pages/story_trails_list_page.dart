import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
// Ensure this path is correct for your project structure
import 'package:real_english/feature/StoryTrails/presentation/widgets/story_generation_loader.dart';
import '../../../../app/injection_container.dart';
import '../bloc/story_trails_list_bloc.dart';

class StoryTrailsListPage extends StatelessWidget {
  const StoryTrailsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use softer, more illustrative backgrounds if available
    final backgroundAsset = isDark
        ? 'assets/images/adventure_background5.png'
        : 'assets/images/adventure_background6.png';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: BlocProvider<StoryTrailsListBloc>(
        create: (context) =>
            sl<StoryTrailsListBloc>()..add(FetchStoryTrailsList()),
        child: BlocBuilder<StoryTrailsListBloc, StoryTrailsListState>(
          builder: (context, state) {
            return Stack(
              children: [
                // -----------------------------------------------------------
                // LAYER 1: Background Image
                // -----------------------------------------------------------
                Positioned.fill(
                  child: Image.asset(
                    backgroundAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: theme.scaffoldBackgroundColor),
                  ),
                ),

                // -----------------------------------------------------------
                // LAYER 2: Soft Natural Overlay
                // -----------------------------------------------------------
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                Colors.transparent,
                                const Color(
                                  0xFF0F1623,
                                ).withValues(alpha: 0.9), // Deep Night
                              ]
                            : [
                                Colors.white.withValues(
                                  alpha: 0.3,
                                ), // Sunny Haze
                                Colors.white.withValues(
                                  alpha: 0.8,
                                ), // Grounding White
                              ],
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),
                ),

                // -----------------------------------------------------------
                // LAYER 3: Main Content
                // -----------------------------------------------------------
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
                          : _buildCardView(context, story, isDark),

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

  /// 📖 The "Storybook" Card View
  /// 📖 The Refined Card View
  Widget _buildCardView(
    BuildContext context,
    StoryTrail storyTrail,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    // 1. Background Color (Reverted to the deep blue you liked)
    final cardColor = isDark
        ? const Color(0xFF0F1623).withValues(alpha: 0.95) // Deep Dark Blue
        : Colors.white.withValues(alpha: 0.95);

    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

    // Soft Primary Color for Icon
    final softIconColor = isDark
        ? const Color(0xFF90CAF9)
        : primaryColor.withValues(alpha: 0.8);

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(32),
              // 2. Stronger Shadow to "Pop" from background
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3), // Darker shadow
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: 2, // Slight spread to make it stand out
                ),
              ],
              // Optional: Subtle border for extra definition in dark mode
              border: isDark
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3. Header: "Current Chapter" (Restored)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_stories_rounded,
                      color: softIconColor, // Soft Primary
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "CURRENT CHAPTER",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800, // Bold
                        color: textColor.withValues(alpha: 0.7),
                        letterSpacing: 1.2, // Wide spacing for elegance
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Cover Image
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Hero(
                      tag: 'story_cover_${storyTrail.id}',
                      child: Image.network(
                        storyTrail.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: isDark ? Colors.grey[900] : Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: primaryColor,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Title
                Text(
                  storyTrail.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 12),

                // 6. Description
                Text(
                  storyTrail.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: textColor.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 32),

                // 7. Action Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/story-player/${storyTrail.id}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: primaryColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      "Play Story",
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers ---

  Widget _buildLoadingState() {
    // Use your custom "Story Alchemy" loader here
    return const StoryAlchemyLoader();
  }

  Widget _buildAllLevelsCompleteView(BuildContext context, int currentLevel) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F).withValues(alpha: 0.2), // Gold
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFD54F),
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Chapter $currentLevel Finished!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Fredoka',
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your garden is blooming. Take a rest, new stories are growing.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, color: Colors.grey[400], size: 60),
          const SizedBox(height: 20),
          Text(
            "The path is hidden...",
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Nunito', color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () =>
                context.read<StoryTrailsListBloc>().add(FetchStoryTrailsList()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
