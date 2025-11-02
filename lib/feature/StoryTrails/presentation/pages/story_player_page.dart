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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        // The title can change based on the state
        title: BlocBuilder<StoryPlayerBloc, StoryPlayerState>(
          builder: (context, state) {
            if (state is StoryPlayerDisplay) {
              return Text(state.storyTrail.title);
            }
            return const Text('');
          },
        ),
      ),
      body: BlocConsumer<StoryPlayerBloc, StoryPlayerState>(
        listener: (context, state) {
          // You can show snackbars for feedback here if you want
          // For example, when an answer is correct/incorrect.
        },
        builder: (context, state) {
          if (state is StoryPlayerLoading || state is StoryPlayerInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StoryPlayerError) {
            return _buildErrorState(context, state.message);
          }

          if (state is StoryPlayerFinished) {
            return _buildFinishedState(context, state);
          }

          if (state is StoryPlayerDisplay) {
            // This is the main view. We build the UI based on the segment type.
            final segment = state.currentSegment;
            switch (segment.type) {
              case SegmentType.narration:
                return _buildNarrationSegment(context, segment);
              case SegmentType.choiceChallenge:
                return _buildChoiceChallengeSegment(context, segment);
              default:
                return Center(
                  child: Text('Unsupported segment type: ${segment.type.name}'),
                );
            }
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
          // TODO: Implement image display from segment.imageUrl
          // if (segment.imageUrl != null) Image.asset(segment.imageUrl!),

          // TODO: Implement audio playback from segment.audioUrl
          // IconButton(icon: Icon(Icons.play_arrow), onPressed: () { ... }),
          Text(
            segment.textContent,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () {
              // In a real app, this would be triggered automatically when the audio finishes.
              context.read<StoryPlayerBloc>().add(NarrationFinished());
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChallengeSegment(
    BuildContext context,
    StorySegment segment,
  ) {
    final theme = Theme.of(context);
    final challenge = segment.challenge as SingleChoiceChallenge;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          }).toList(),
        ],
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
                // Navigate back to the list of stories
                context.go('/story-trails');
              },
              child: const Text('Back to Adventures'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 16),
            Text(
              'Oh no!',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // This assumes the trailId is accessible. A real implementation might need to
                // get the trailId from the current state if possible, or pass it down.
                // For now, this approach is simplified. A better way is to get it from the state.
                final currentState = context.read<StoryPlayerBloc>().state;
                // A more robust way would be to store the trailId in the state itself.
                // For now, this shows the intent.
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
