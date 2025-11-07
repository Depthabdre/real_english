import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../app/injection_container.dart';
import '../../domain/entities/single_choice_challenge.dart';
import '../../domain/entities/story_segment.dart';
import '../bloc/story_player_bloc.dart';

class StoryPlayerPage extends StatelessWidget {
  final String trailId;
  const StoryPlayerPage({super.key, required this.trailId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StoryPlayerBloc>(
      create: (context) => sl<StoryPlayerBloc>()..add(StartStory(trailId: trailId)),
      child: const StoryPlayerView(),
    );
  }
}

// Converted to a StatefulWidget to manage TTS and AudioPlayer controllers
class StoryPlayerView extends StatefulWidget {
  const StoryPlayerView({super.key});

  @override
  State<StoryPlayerView> createState() => _StoryPlayerViewState();
}

class _StoryPlayerViewState extends State<StoryPlayerView> {
  late final FlutterTts _flutterTts;
  late final AudioPlayer _soundPlayer;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _soundPlayer = AudioPlayer();
    _setupTts();
  }

  Future<void> _setupTts() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _soundPlayer.dispose();
    super.dispose();
  }

  void _speak(String text) {
    _flutterTts.speak(text);
  }

  void _playFeedbackSound(bool isCorrect) async {
    final assetPath = 'assets/sounds/${isCorrect ? 'correct.mp3' : 'incorrect.mp3'}';
    try {
      await _soundPlayer.setAsset(assetPath);
      _soundPlayer.play();
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _showFeedback(BuildContext context, bool isCorrect, String message) {
    _playFeedbackSound(isCorrect);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<StoryPlayerBloc, StoryPlayerState>(
          builder: (context, state) {
            if (state is StoryPlayerDisplay) {
              return Text(state.storyTrail.title);
            } else if (state is AnswerFeedback) {
              return Text(state.displayState.storyTrail.title);
            }
            return const Text('');
          },
        ),
      ),
      body: BlocListener<StoryPlayerBloc, StoryPlayerState>(
        listener: (context, state) {
          if (state is StoryPlayerDisplay) {
            final textToSpeak = state.currentSegment.type == SegmentType.narration
                ? state.currentSegment.textContent
                : (state.currentSegment.challenge as SingleChoiceChallenge).prompt;
            _speak(textToSpeak);
          } else if (state is AnswerFeedback) {
            _showFeedback(context, state.isCorrect, state.feedbackMessage);
          }
        },
        child: BlocBuilder<StoryPlayerBloc, StoryPlayerState>(
          builder: (context, state) {
            if (state is StoryPlayerInitial || state is StoryPlayerLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is StoryPlayerError) return _buildErrorState(context, state);
            if (state is LevelCompleted) return _buildLevelCompletedState(context, state);
            if (state is StoryPlayerFinished) return _buildFinishedState(context, state);

            StorySegment? segment;
            if (state is StoryPlayerDisplay) {
              segment = state.currentSegment;
            } else if (state is AnswerFeedback) {
              segment = state.displayState.currentSegment;
            }

            if (segment != null) {
              return _buildContent(context, segment);
            }
            
            return const Center(child: Text('An unknown state occurred.'));
          },
        ),
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, StorySegment segment) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey<String>(segment.id),
        child: switch (segment.type) {
          SegmentType.narration => _buildNarrationSegment(context, segment),
          SegmentType.choiceChallenge => _buildChoiceChallengeSegment(context, segment),
          _ => Center(child: Text('Unsupported segment type: ${segment.type.name}')),
        },
      ),
    );
  }

  Widget _buildNarrationSegment(BuildContext context, StorySegment segment) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSegmentImage(segment.imageUrl),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  segment.textContent,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: () => _speak(segment.textContent),
                tooltip: 'Listen again',
              ),
            ],
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: () => context.read<StoryPlayerBloc>().add(NarrationFinished()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChoiceChallengeSegment(BuildContext context, StorySegment segment) {
    final theme = Theme.of(context);
    final challenge = segment.challenge as SingleChoiceChallenge;
    bool isResponding = context.watch<StoryPlayerBloc>().state is AnswerFeedback;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSegmentImage(segment.imageUrl),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  challenge.prompt,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up_rounded),
                onPressed: () => _speak(challenge.prompt),
                tooltip: 'Listen again',
              ),
            ],
          ),
          const SizedBox(height: 48),
          ...challenge.choices.map((choice) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: isResponding
                    ? null
                    : () => context.read<StoryPlayerBloc>().add(SubmitAnswer(chosenAnswerId: choice.id)),
                child: Text(choice.text),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSegmentImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox(height: 200); // Reserve space even if no image
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
  
  Widget _buildLevelCompletedState(BuildContext context, LevelCompleted state) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 100),
            const SizedBox(height: 24),
            Text(
              'Level Complete!',
              style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'You have mastered all the stories in this level. Get ready for new adventures in Level ${state.newLevel}!',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
              onPressed: () => context.go('/story-trails'),
              child: const Text('Explore Next Level'),
            )
          ],
        ),
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
              onPressed: () => context.go('/story-trails'),
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
              onPressed: () => context.read<StoryPlayerBloc>().add(StartStory(trailId: state.trailId)),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}