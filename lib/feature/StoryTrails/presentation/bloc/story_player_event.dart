part of 'story_player_bloc.dart';

abstract class StoryPlayerEvent extends Equatable {
  const StoryPlayerEvent();

  @override
  List<Object> get props => [];
}

class StartStory extends StoryPlayerEvent {
  final String trailId;
  const StartStory({required this.trailId});
  @override
  List<Object> get props => [trailId];
}

class SubmitAnswer extends StoryPlayerEvent {
  final String chosenAnswerId;
  const SubmitAnswer({required this.chosenAnswerId});
  @override
  List<Object> get props => [chosenAnswerId];
}

class ReplayAudio extends StoryPlayerEvent {}

class NarrationFinished extends StoryPlayerEvent {}

// --- UPDATED: Payload is now String audioUrl ---
class _AudioPreloaded extends StoryPlayerEvent {
  final String segmentId;
  final String audioUrl;

  const _AudioPreloaded({required this.segmentId, required this.audioUrl});
}
