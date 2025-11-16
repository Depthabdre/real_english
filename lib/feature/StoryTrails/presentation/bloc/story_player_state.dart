part of 'story_player_bloc.dart';

abstract class StoryPlayerState extends Equatable {
  const StoryPlayerState();
  @override
  List<Object?> get props => [];
}

class StoryPlayerInitial extends StoryPlayerState {}

class StoryPlayerLoading extends StoryPlayerState {}

class StoryPlayerDisplay extends StoryPlayerState {
  final StoryTrail storyTrail;
  final StoryProgress progress;

  // --- NEW: A cache to hold preloaded audio data ---
  final Map<String, Uint8List> audioCache;

  const StoryPlayerDisplay({
    required this.storyTrail,
    required this.progress,
    this.audioCache = const {}, // Default to an empty map
  });

  int get currentSegmentIndex => progress.currentSegmentIndex;
  StorySegment get currentSegment => storyTrail.segments[currentSegmentIndex];

  @override
  List<Object?> get props => [storyTrail, progress, audioCache];

  // --- NEW: A full copyWith method for easier state updates ---
  StoryPlayerDisplay copyWith({
    StoryTrail? storyTrail,
    StoryProgress? progress,
    Map<String, Uint8List>? audioCache,
  }) {
    return StoryPlayerDisplay(
      storyTrail: storyTrail ?? this.storyTrail,
      progress: progress ?? this.progress,
      audioCache: audioCache ?? this.audioCache,
    );
  }
}

class AnswerFeedback extends StoryPlayerState {
  final bool isCorrect;
  final String feedbackMessage;
  final StoryPlayerDisplay displayState;

  const AnswerFeedback({
    required this.isCorrect,
    required this.feedbackMessage,
    required this.displayState,
  });

  @override
  List<Object?> get props => [isCorrect, feedbackMessage, displayState];
}

class StoryPlayerFinished extends StoryPlayerState {
  final StoryProgress finalProgress;
  const StoryPlayerFinished({required this.finalProgress});
  @override
  List<Object> get props => [finalProgress];
}

class LevelCompleted extends StoryPlayerState {
  final int newLevel;
  const LevelCompleted({required this.newLevel});
  @override
  List<Object> get props => [newLevel];
}

class StoryPlayerError extends StoryPlayerState {
  final String message;
  final String trailId;
  const StoryPlayerError(this.message, this.trailId);
  @override
  List<Object> get props => [message, trailId];
}
