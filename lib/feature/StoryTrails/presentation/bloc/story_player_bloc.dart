// presentation/bloc/story_player_bloc.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:real_english/feature/StoryTrails/data/models/story_progress_model.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_progress.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import 'package:real_english/feature/StoryTrails/domain/usecases/get_story_trail_by_id.dart';
import 'package:real_english/feature/StoryTrails/domain/usecases/get_user_story_progress.dart';
import 'package:real_english/feature/StoryTrails/domain/usecases/mark_story_trail_completed.dart';
import 'package:real_english/feature/StoryTrails/domain/usecases/save_user_story_progress.dart';
import 'package:real_english/feature/StoryTrails/domain/usecases/submit_challenge_answer.dart';

// Use 'part' to include the event and state files as part of this library
part 'story_player_event.dart';
part 'story_player_state.dart';


class StoryPlayerBloc extends Bloc<StoryPlayerEvent, StoryPlayerState> {
  final GetStoryTrailById getStoryTrailByIdUseCase;
  final GetUserStoryProgress getUserStoryProgressUseCase;
  final SubmitChallengeAnswer submitChallengeAnswerUseCase;
  final SaveUserStoryProgress saveUserStoryProgressUseCase;
  final MarkStoryTrailCompleted markStoryTrailCompletedUseCase;

  StoryPlayerBloc({
    required this.getStoryTrailByIdUseCase,
    required this.getUserStoryProgressUseCase,
    required this.submitChallengeAnswerUseCase,
    required this.saveUserStoryProgressUseCase,
    required this.markStoryTrailCompletedUseCase,
  }) : super(StoryPlayerInitial()) {
    on<StartStory>(_onStartStory);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<NarrationFinished>(_onNarrationFinished);
  }

  /// Handles loading the initial story data.
  Future<void> _onStartStory(StartStory event, Emitter<StoryPlayerState> emit) async {
    emit(StoryPlayerLoading());

    final trailResult = await getStoryTrailByIdUseCase(GetStoryTrailByIdParams(trailId: event.trailId));
    final progressResult = await getUserStoryProgressUseCase(GetUserStoryProgressParams(trailId: event.trailId));

    // Use fold to handle success/failure of both API calls
    await trailResult.fold(
      (failure) async => emit(StoryPlayerError(failure.message)),
      (trail) async {
        await progressResult.fold(
          (failure) async => emit(StoryPlayerError(failure.message)),
          (progress) async {
            // Success: Emit the display state with the loaded data
            emit(StoryPlayerDisplay(
              storyTrail: trail,
              progress: progress,
              currentSegmentIndex: progress.currentSegmentIndex,
            ));
          },
        );
      },
    );
  }

  /// Handles the user's answer to a challenge.
  Future<void> _onSubmitAnswer(SubmitAnswer event, Emitter<StoryPlayerState> emit) async {
    final currentState = state;
    if (currentState is! StoryPlayerDisplay) return; // Can only submit answers while displaying

    final currentSegment = currentState.currentSegment;
    if (currentSegment.challenge == null) return; // Should not happen

    final result = await submitChallengeAnswerUseCase(SubmitChallengeAnswerParams(
      trailId: currentState.storyTrail.id,
      segmentId: currentSegment.id,
      challengeId: currentSegment.challenge!.id,
      userAnswer: event.chosenAnswerId,
    ));

    await result.fold(
      (failure) async => emit(StoryPlayerError(failure.message)),
      (updatedProgress) async {
        // After a successful answer, advance to the next segment
        _advanceToNextSegment(
          emit,
          currentState.storyTrail,
          updatedProgress,
          currentState.currentSegmentIndex,
        );
      },
    );
  }
  
  /// Handles advancing the story after a narration segment is complete.
  Future<void> _onNarrationFinished(NarrationFinished event, Emitter<StoryPlayerState> emit) async {
    final currentState = state;
    if (currentState is! StoryPlayerDisplay) return;

    // Just advance to the next segment with the current progress
     _advanceToNextSegment(
      emit,
      currentState.storyTrail,
      currentState.progress,
      currentState.currentSegmentIndex,
    );
  }


  /// A shared helper method to advance the story to the next segment or finish it.
  Future<void> _advanceToNextSegment(
    Emitter<StoryPlayerState> emit,
    StoryTrail trail,
    StoryProgress currentProgress,
    int currentSegmentIndex,
  ) async {
    final nextIndex = currentSegmentIndex + 1;

    // Check if the story is finished
    if (nextIndex >= trail.segments.length) {
      // Mark the trail as completed in the backend/local storage
      await markStoryTrailCompletedUseCase(
        MarkStoryTrailCompletedParams(trailId: trail.id),
      );
      // Emit the finished state
      emit(StoryPlayerFinished(finalProgress: currentProgress));
    } else {
      // If not finished, update the progress with the new segment index
      final newProgress = (currentProgress as StoryProgressModel).copyWith(
        currentSegmentIndex: nextIndex,
      );
      
      // Save the updated progress so the user can resume from the next segment
      await saveUserStoryProgressUseCase(
        SaveUserStoryProgressParams(progress: newProgress),
      );

      // Emit the display state for the new segment
      emit(StoryPlayerDisplay(
        storyTrail: trail,
        progress: newProgress,
        currentSegmentIndex: nextIndex,
      ));
    }
  }
}