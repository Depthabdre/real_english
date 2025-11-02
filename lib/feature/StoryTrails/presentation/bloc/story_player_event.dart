// presentation/bloc/story_player_event.dart

part of 'story_player_bloc.dart'; // Connects to the main BLoC file

abstract class StoryPlayerEvent extends Equatable {
  const StoryPlayerEvent();

  @override
  List<Object> get props => [];
}

/// Dispatched when the player page is first loaded to start a specific story.
class StartStory extends StoryPlayerEvent {
  final String trailId;

  const StartStory({required this.trailId});

  @override
  List<Object> get props => [trailId];
}

/// Dispatched when the user submits an answer to a challenge.
class SubmitAnswer extends StoryPlayerEvent {
  final String chosenAnswerId; // The ID of the choice the user selected

  const SubmitAnswer({required this.chosenAnswerId});

  @override
  List<Object> get props => [chosenAnswerId];
}

/// Dispatched by the UI when a narration segment (e.g., audio) has finished playing.
class NarrationFinished extends StoryPlayerEvent {}
