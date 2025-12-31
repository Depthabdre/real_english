import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import 'package:real_english/feature/StoryTrails/presentation/widgets/story_generation_loader.dart';
import '../../../../app/injection_container.dart';
import '../bloc/story_trails_list_bloc.dart';

class StoryTrailsListPage extends StatelessWidget {
  const StoryTrailsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Detect Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Select Background Asset based on Theme
    final backgroundAsset = isDark
        ? 'assets/images/adventure_background5.png'
        : 'assets/images/adventure_background6.png';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocProvider<StoryTrailsListBloc>(
        create: (context) =>
            sl<StoryTrailsListBloc>()..add(FetchStoryTrailsList()),
        child: BlocBuilder<StoryTrailsListBloc, StoryTrailsListState>(
          builder: (context, state) {
            return Stack(
              children: [
                // -----------------------------------------------------------
                // LAYER 1: Background Image (Dynamic)
                // -----------------------------------------------------------
                Positioned.fill(
                  child: Image.asset(
                    backgroundAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: isDark
                          ? const Color(0xFF1A2332)
                          : Colors.blueGrey[50],
                    ),
                  ),
                ),

                // -----------------------------------------------------------
                // LAYER 2: Overlay (Dynamic)
                // -----------------------------------------------------------
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.2,
                        colors: isDark
                            ? [
                                // Dark Mode: Transparent -> Black Vignette
                                Colors.transparent,
                                const Color(0xFF000000).withValues(alpha: 0.85),
                              ]
                            : [
                                // Light Mode: Light Haze -> White Vignette
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.5),
                              ],
                        stops: const [0.2, 1.0],
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

  /// 🌟 The Main UI Builder
  Widget _buildCardView(
    BuildContext context,
    StoryTrail storyTrail,
    bool isDark,
  ) {
    // 1. Dynamic Colors for Card Fill and Text
    final cardColor = isDark
        ? const Color(0xFF0F1623).withValues(alpha: 0.98) // Deep Dark Blue
        : Colors.white.withValues(alpha: 0.95); // White

    final textColor = isDark ? Colors.white : const Color(0xFF212121);
    final descColor = isDark
        ? const Color(0xFFB0BEC5)
        : const Color(0xFF546E7A);
    final iconColor = isDark ? Colors.white : Colors.blue[800];

    // 2. Fixed "Neon" Elements (Shadow & Border) - Same for BOTH modes
    final glowShadow = BoxShadow(
      color: const Color(0xFF42A5F5).withValues(alpha: 0.6), // Bright Blue Glow
      blurRadius: 50,
      spreadRadius: 0,
      offset: const Offset(0, 0),
    );

    final borderStyle = Border.all(
      color: const Color(0xFF64B5F6), // Bright Blue Border
      width: 1.5, // Very little border
    );

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(35),
              border: borderStyle, // Blue Border
              boxShadow: [
                glowShadow, // Blue Shadow
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Header: Icon + "Story Trails" (Inside Card)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.explore, color: iconColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Story Trails",
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 2. The Rectangular Image
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    // Minimal Shadow for image
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Hero(
                      tag: 'story_cover_${storyTrail.id}',
                      child: Image.network(
                        storyTrail.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: Colors.grey[900],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 3. Story Title
                Text(
                  storyTrail.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'RobotoCondensed',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textColor, // Dynamic Text Color
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Description
                Text(
                  storyTrail.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: descColor, // Dynamic Desc Color
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // 5. Gradient Button (Blue gradient for both)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF90CAF9), Color(0xFF42A5F5)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF42A5F5).withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/story-player/${storyTrail.id}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "START YOUR JOURNEY",
                        style: TextStyle(
                          color: Colors
                              .black87, // Always black on this bright button
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
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
    return const StoryGenerationLoader();
  }

  Widget _buildAllLevelsCompleteView(BuildContext context, int currentLevel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF0F1623).withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          // Consistent Blue Border/Shadow here too
          border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF42A5F5).withValues(alpha: 0.6),
              blurRadius: 30,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, color: Colors.amber, size: 60),
            const SizedBox(height: 20),
            Text(
              "Level $currentLevel Complete!",
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Check back soon for new adventures.",
              textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.grey : Colors.grey[700]),
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
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 50),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () =>
                context.read<StoryTrailsListBloc>().add(FetchStoryTrailsList()),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
