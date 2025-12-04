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
  // If this ID matches the segment ID, it means audio has started.
  final String? playingSegmentId;

  const StoryPlayerDisplay({
    required this.storyTrail,
    required this.progress,
    this.audioCache = const {},
    this.playingSegmentId,
  });

  int get currentSegmentIndex => progress.currentSegmentIndex;
  StorySegment get currentSegment => storyTrail.segments[currentSegmentIndex];

  @override
  List<Object?> get props => [
    storyTrail,
    progress,
    audioCache,
    playingSegmentId,
  ];

  StoryPlayerDisplay copyWith({
    StoryTrail? storyTrail,
    StoryProgress? progress,
    Map<String, String>? audioCache,
    String? playingSegmentId, // Add to copyWith
  }) {
    return StoryPlayerDisplay(
      storyTrail: storyTrail ?? this.storyTrail,
      progress: progress ?? this.progress,
      audioCache: audioCache ?? this.audioCache,
      // If null is passed, we keep existing.
      // If we want to clear it, we might need a specific logic,
      // but usually overwriting with a new ID is enough.
      playingSegmentId: playingSegmentId ?? this.playingSegmentId,
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
  final String storyTitle; // <--- Added for consistency

  const StoryPlayerFinished({
    required this.finalProgress,
    required this.storyTitle, // <--- Added
  });

  @override
  List<Object> get props => [finalProgress, storyTitle];
}

class LevelCompleted extends StoryPlayerState {
  final int newLevel;
  final String storyTitle; // <--- Added

  const LevelCompleted({
    required this.newLevel,
    required this.storyTitle, // <--- Added
  });

  @override
  List<Object> get props => [newLevel, storyTitle];
}

class StoryPlayerError extends StoryPlayerState {
  final String message;
  final String trailId;
  const StoryPlayerError(this.message, this.trailId);
  @override
  List<Object> get props => [message, trailId];
}
