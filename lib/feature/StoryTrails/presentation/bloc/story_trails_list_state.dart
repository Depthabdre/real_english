part of 'story_trails_list_bloc.dart';

abstract class StoryTrailsListState extends Equatable {
  const StoryTrailsListState();
  @override
  List<Object?> get props => [];
}

class StoryTrailsListInitial extends StoryTrailsListState {}

class StoryTrailsListLoading extends StoryTrailsListState {}

class StoryTrailsListLoaded extends StoryTrailsListState {
  // --- CHANGE: From List<StoryTrail> to StoryTrail? ---
  // A non-null value means we have a story to show.
  // A null value means the user has completed all stories for the level.
  final StoryTrail? storyTrail;
  final int currentLevel;

  const StoryTrailsListLoaded({
    required this.storyTrail,
    required this.currentLevel,
  });

  @override
  List<Object?> get props => [storyTrail, currentLevel];
}

class StoryTrailsListError extends StoryTrailsListState {
  final String message;
  const StoryTrailsListError(this.message);
  @override
  List<Object> get props => [message];
}
