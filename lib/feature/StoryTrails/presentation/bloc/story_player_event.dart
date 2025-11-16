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

/// Dispatched automatically by the BLoC's audio player listener when a narration finishes.
class NarrationFinished extends StoryPlayerEvent {}

// --- NEW INTERNAL EVENT ---
/// This event is added by the BLoC to itself when a background
/// audio preload has finished downloading.
class _AudioPreloaded extends StoryPlayerEvent {
  final String segmentId;
  final Uint8List audioData;

  const _AudioPreloaded({required this.segmentId, required this.audioData});
}
