// presentation/bloc/story_player_state.dart
part of 'story_player_bloc.dart';

abstract class StoryPlayerState extends Equatable {
  const StoryPlayerState();
  @override
  List<Object> get props => [];
}

class StoryPlayerInitial extends StoryPlayerState {}

class StoryPlayerLoading extends StoryPlayerState {}

class StoryPlayerDisplay extends StoryPlayerState {
  final StoryTrail storyTrail;
  final StoryProgress progress;

  const StoryPlayerDisplay({required this.storyTrail, required this.progress});

  int get currentSegmentIndex => progress.currentSegmentIndex;
  StorySegment get currentSegment => storyTrail.segments[currentSegmentIndex];

  @override
  List<Object> get props => [storyTrail, progress]; // Simpler and more reliable
}

class StoryPlayerFinished extends StoryPlayerState {
  final StoryProgress finalProgress;
  const StoryPlayerFinished({required this.finalProgress});
  @override
  List<Object> get props => [finalProgress];
}

class StoryPlayerError extends StoryPlayerState {
  final String message;
  final String trailId; // Added to allow for a reliable retry
  const StoryPlayerError(this.message, this.trailId);
  @override
  List<Object> get props => [message, trailId];
}
