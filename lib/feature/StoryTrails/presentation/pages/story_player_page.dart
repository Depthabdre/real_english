import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/single_choice_challenge.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';

import '../../../../app/injection_container.dart';
import '../bloc/story_player_bloc.dart';

class StoryPlayerPage extends StatelessWidget {
  final String trailId;

  const StoryPlayerPage({super.key, required this.trailId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoryPlayerBloc>(
      create: (context) =>
          sl<StoryPlayerBloc>()..add(StartStory(trailId: trailId)),
      child: const StoryPlayerView(),
    );
  }
}

class StoryPlayerView extends StatelessWidget {
  const StoryPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<StoryPlayerBloc, StoryPlayerState>(
          builder: (context, state) {
            if (state is StoryPlayerDisplay) {
              return Text(state.storyTrail.title);
            }
            return const Text('');
          },
        ),
      ),
      body: BlocBuilder<StoryPlayerBloc, StoryPlayerState>(
        builder: (context, state) {
          if (state is StoryPlayerLoading || state is StoryPlayerInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StoryPlayerError) {
            return _buildErrorState(context, state);
          }

          if (state is StoryPlayerFinished) {
            return _buildFinishedState(context, state);
          }

          if (state is StoryPlayerDisplay) {
            final segment = state.currentSegment;
            // Use AnimatedSwitcher for smooth transitions between segments
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Container(
                // Add a key to help AnimatedSwitcher differentiate widgets
                key: ValueKey<String>(segment.id),
                child: switch (segment.type) {
                  SegmentType.narration => _buildNarrationSegment(context, segment),
                  SegmentType.choiceChallenge => _buildChoiceChallengeSegment(context, segment),
                  _ => Center(child: Text('Unsupported segment type: ${segment.type.name}')),
                },
              ),
            );
          }

          return const Center(child: Text('An unknown state occurred.'));
        },
      ),
    );
  }

  // --- WIDGET BUILDERS FOR DIFFERENT STATES AND SEGMENTS ---

  Widget _buildNarrationSegment(BuildContext context, StorySegment segment) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSegmentImage(segment.imageUrl), // Reusable image widget
          const SizedBox(height: 24),
          Text(
            segment.textContent,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              context.read<StoryPlayerBloc>().add(NarrationFinished());
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChallengeSegment(BuildContext context, StorySegment segment) {
    final theme = Theme.of(context);
    final challenge = segment.challenge as SingleChoiceChallenge;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSegmentImage(segment.imageUrl), // Reusable image widget
          const SizedBox(height: 24),
          Text(
            challenge.prompt,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ...challenge.choices.map((choice) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  context.read<StoryPlayerBloc>().add(
                        SubmitAnswer(chosenAnswerId: choice.id),
                      );
                },
                child: Text(choice.text),
              ),
            );
          }),
        ],
      ),
    );
  }

  // A new reusable widget to handle image display
  Widget _buildSegmentImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if there's no image
    }
    return Container(
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image_outlined, size: 48, color: Colors.grey);
        },
      ),
    );
  }

  Widget _buildFinishedState(BuildContext context, StoryPlayerFinished state) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.park_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            Text('Story Complete!', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text(
              'Great job! You earned ${state.finalProgress.xpEarned} XP. Your learning tree grew a little taller! 🌳',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                context.go('/story-trails');
              },
              child: const Text('Back to Adventures'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, StoryPlayerError state) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            Text('Oh no!', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(state.message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Use the trailId from the state to reliably retry.
                context.read<StoryPlayerBloc>().add(StartStory(trailId: state.trailId));
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}