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

  // --- UPDATED: Cache stores URL Strings now, not Uint8List ---
  final Map<String, String> audioCache;

  const StoryPlayerDisplay({
    required this.storyTrail,
    required this.progress,
    this.audioCache = const {},
  });

  int get currentSegmentIndex => progress.currentSegmentIndex;
  StorySegment get currentSegment => storyTrail.segments[currentSegmentIndex];

  @override
  List<Object?> get props => [storyTrail, progress, audioCache];

  StoryPlayerDisplay copyWith({
    StoryTrail? storyTrail,
    StoryProgress? progress,
    Map<String, String>? audioCache, // Updated type here too
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
