import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import 'package:real_english/feature/StoryTrails/domain/usecases/get_story_trail_for_level.dart';
import 'package:real_english/feature/StoryTrails/domain/usecases/get_user_learning_profile.dart';

part 'story_trails_list_event.dart';
part 'story_trails_list_state.dart';



class StoryTrailsListBloc extends Bloc<StoryTrailsListEvent, StoryTrailsListState> {
  final GetUserLearningProfile getUserLearningProfileUseCase;
  // --- CHANGE: Use the new singular use case ---
  final GetStoryTrailForLevel getStoryTrailForLevelUseCase;

  StoryTrailsListBloc({
    required this.getUserLearningProfileUseCase,
    required this.getStoryTrailForLevelUseCase, // Updated dependency
  }) : super(StoryTrailsListInitial()) {
    on<FetchStoryTrailsList>(_onFetchStoryTrailsList);
  }

  Future<void> _onFetchStoryTrailsList(
    FetchStoryTrailsList event,
    Emitter<StoryTrailsListState> emit,
  ) async {
    emit(StoryTrailsListLoading());

    final profileResult = await getUserLearningProfileUseCase();

    await profileResult.fold(
      (failure) async => emit(StoryTrailsListError(failure.message)),
      (learningProfile) async {
        // --- CHANGE: Call the new singular use case ---
        final trailResult = await getStoryTrailForLevelUseCase(
          GetStoryTrailForLevelParams(level: learningProfile.currentLearningLevel),
        );

        trailResult.fold(
          (failure) => emit(StoryTrailsListError(failure.message)),
          // The result is now a single nullable storyTrail
          (storyTrail) => emit(StoryTrailsListLoaded(
            storyTrail: storyTrail,
            currentLevel: learningProfile.currentLearningLevel,
          )),
        );
      },
    );
  }
}