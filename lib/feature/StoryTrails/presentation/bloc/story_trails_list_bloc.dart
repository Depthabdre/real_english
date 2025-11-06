// presentation/bloc/story_trails_list_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import '../../domain/usecases/get_user_learning_profile.dart';
import '../../domain/usecases/get_story_trail_for_level.dart';

// Import the events and states we just created
part 'story_trails_list_event.dart';
part 'story_trails_list_state.dart';

// Import the necessary use cases from the domain layer

class StoryTrailsListBloc
    extends Bloc<StoryTrailsListEvent, StoryTrailsListState> {
  final GetUserLearningProfile getUserLearningProfileUseCase;
  final GetStoryTrailsForLevel getStoryTrailsForLevelUseCase;

  StoryTrailsListBloc({
    required this.getUserLearningProfileUseCase,
    required this.getStoryTrailsForLevelUseCase,
  }) : super(StoryTrailsListInitial()) {
    // Register the event handler for when the UI wants to fetch stories
    on<FetchStoryTrailsList>(_onFetchStoryTrailsList);
  }

  /// Handles the [FetchStoryTrailsList] event.
  Future<void> _onFetchStoryTrailsList(
    FetchStoryTrailsList event,
    Emitter<StoryTrailsListState> emit,
  ) async {
    // 1. Immediately emit the loading state to show a spinner in the UI.
    emit(StoryTrailsListLoading());

    // 2. First, get the user's learning profile to find out their current level.
    final profileResult = await getUserLearningProfileUseCase();

    // 3. Handle the result of the profile fetch.
    await profileResult.fold(
      // If fetching the profile fails, emit an error state.
      (failure) async {
        emit(StoryTrailsListError(failure.message));
      },
      // If fetching the profile succeeds...
      (learningProfile) async {
        // 4. Now use the user's current level to fetch the corresponding story trails.
        final trailsResult = await getStoryTrailsForLevelUseCase(
          GetStoryTrailsForLevelParams(
            level: learningProfile.currentLearningLevel,
          ),
        );

        // 5. Handle the result of the story trails fetch.
        trailsResult.fold(
          // If fetching trails fails, emit an error state.
          (failure) => emit(StoryTrailsListError(failure.message)),
          // If fetching trails succeeds, emit the loaded state with the data.
          (storyTrails) => emit(
            StoryTrailsListLoaded(
              storyTrails: storyTrails,
              currentLevel: learningProfile.currentLearningLevel,
            ),
          ),
        );
      },
    );
  }
}
