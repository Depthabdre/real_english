// presentation/bloc/story_trails_list_state.dart
part of "story_trails_list_bloc.dart";

abstract class StoryTrailsListState extends Equatable {
  const StoryTrailsListState();

  @override
  List<Object> get props => [];
}

/// The initial state of the feature before anything has happened.
class StoryTrailsListInitial extends StoryTrailsListState {}

/// State indicating that the list of story trails is currently being fetched.
/// The UI should show a loading indicator.
class StoryTrailsListLoading extends StoryTrailsListState {}

/// State indicating that the list of story trails has been successfully loaded.
class StoryTrailsListLoaded extends StoryTrailsListState {
  final List<StoryTrail> storyTrails;
  final int currentLevel;

  const StoryTrailsListLoaded({
    required this.storyTrails,
    required this.currentLevel,
  });

  @override
  List<Object> get props => [storyTrails, currentLevel];
}

/// State indicating that an error occurred while fetching the story trails.
/// The UI should show an error message.
class StoryTrailsListError extends StoryTrailsListState {
  final String message;

  const StoryTrailsListError(this.message);

  @override
  List<Object> get props => [message];
}
