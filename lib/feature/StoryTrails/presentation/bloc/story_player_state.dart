// presentation/bloc/story_player_state.dart

part of 'story_player_bloc.dart'; // Connects to the main BLoC file

abstract class StoryPlayerState extends Equatable {
  const StoryPlayerState();

  @override
  List<Object> get props => [];
}

/// Initial state before a story is loaded.
class StoryPlayerInitial extends StoryPlayerState {}

/// State when the story trail data is being fetched.
class StoryPlayerLoading extends StoryPlayerState {}

/// The main state during gameplay. It provides the UI with all the data
/// needed to display the current segment of the story.
class StoryPlayerDisplay extends StoryPlayerState {
  final StoryTrail storyTrail;
  final StoryProgress progress;
  final int currentSegmentIndex;

  const StoryPlayerDisplay({
    required this.storyTrail,
    required this.progress,
    required this.currentSegmentIndex,
  });

  /// A helper getter to easily access the current segment.
  StorySegment get currentSegment => storyTrail.segments[currentSegmentIndex];

  @override
  List<Object> get props => [storyTrail, progress, currentSegmentIndex];
}

/// State when the story has been successfully completed.
class StoryPlayerFinished extends StoryPlayerState {
  final StoryProgress finalProgress;

  const StoryPlayerFinished({required this.finalProgress});

  @override
  List<Object> get props => [finalProgress];
}

/// State when an error occurs during story loading or gameplay.
class StoryPlayerError extends StoryPlayerState {
  final String message;

  const StoryPlayerError(this.message);

  @override
  List<Object> get props => [message];
}
