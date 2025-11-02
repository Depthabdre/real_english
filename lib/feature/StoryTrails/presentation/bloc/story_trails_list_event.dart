// presentation/bloc/story_trails_list_event.dart

part of 'story_trails_list_bloc.dart';

abstract class StoryTrailsListEvent extends Equatable {
  const StoryTrailsListEvent();

  @override
  List<Object> get props => [];
}

/// Event dispatched to fetch the story trails for the user's current level.
class FetchStoryTrailsList extends StoryTrailsListEvent {}
