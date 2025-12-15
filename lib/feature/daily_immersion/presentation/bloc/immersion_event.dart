part of 'immersion_bloc.dart';

abstract class ImmersionEvent extends Equatable {
  const ImmersionEvent();
  @override
  List<Object> get props => [];
}

class LoadImmersionFeed extends ImmersionEvent {
  final String category;
  const LoadImmersionFeed({this.category = 'mix'});
  @override
  List<Object> get props => [category];
}

// --- NEW EVENT ---
class LoadMoreImmersionFeed extends ImmersionEvent {
  const LoadMoreImmersionFeed();
}

/// Triggered when user taps the "Heart" icon
class ToggleSaveShort extends ImmersionEvent {
  final String shortId;

  const ToggleSaveShort(this.shortId);

  @override
  List<Object> get props => [shortId];
}

/// Triggered when a video finishes or user clicks "I got it"
class MarkShortAsWatched extends ImmersionEvent {
  final String shortId;

  const MarkShortAsWatched(this.shortId);

  @override
  List<Object> get props => [shortId];
}
