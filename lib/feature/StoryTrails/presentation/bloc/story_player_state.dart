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
  final Map<String, String> audioCache;
  final Duration? currentAudioDuration; // Tells UI how fast to type
  final String?
  playingSegmentId; // Tells UI *which* segment is actually playing (hides text if null)

  const StoryPlayerDisplay({
    required this.storyTrail,
    required this.progress,
    this.audioCache = const {},
    this.currentAudioDuration,
    this.playingSegmentId, // Add to constructor
  });

  int get currentSegmentIndex => progress.currentSegmentIndex;
  StorySegment get currentSegment => storyTrail.segments[currentSegmentIndex];

  @override
  List<Object?> get props => [
    storyTrail,
    progress,
    audioCache,
    currentAudioDuration,
    playingSegmentId,
  ];

  // --- UPDATED COPYWITH ---
  StoryPlayerDisplay copyWith({
    StoryTrail? storyTrail,
    StoryProgress? progress,
    Map<String, String>? audioCache,
    Duration? currentAudioDuration,
    String? playingSegmentId, // Add to parameters
  }) {
    return StoryPlayerDisplay(
      storyTrail: storyTrail ?? this.storyTrail,
      progress: progress ?? this.progress,
      audioCache: audioCache ?? this.audioCache,
      currentAudioDuration: currentAudioDuration ?? this.currentAudioDuration,
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
