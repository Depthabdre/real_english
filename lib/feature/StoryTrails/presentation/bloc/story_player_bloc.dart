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
  Future<void> _onStartStory(
    StartStory event,
    Emitter<StoryPlayerState> emit,
  ) async {
    emit(StoryPlayerLoading());

    final trailResult = await getStoryTrailByIdUseCase(
      GetStoryTrailByIdParams(trailId: event.trailId),
    );

    await trailResult.fold(
      (failure) async => emit(StoryPlayerError(failure.message, event.trailId)),
      (trail) async {
        final progressResult = await getUserStoryProgressUseCase(
          GetUserStoryProgressParams(trailId: event.trailId),
        );

        await progressResult.fold(
          (failure) async =>
              emit(StoryPlayerError(failure.message, event.trailId)),
          (progress) async {
            emit(StoryPlayerDisplay(storyTrail: trail, progress: progress));
          },
        );
      },
    );
  }

  /// Handles the user's answer to a challenge.
  Future<void> _onSubmitAnswer(
    SubmitAnswer event,
    Emitter<StoryPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StoryPlayerDisplay) return;

    final currentSegment = currentState.currentSegment;
    if (currentSegment.challenge == null) return;

    final result = await submitChallengeAnswerUseCase(
      SubmitChallengeAnswerParams(
        trailId: currentState.storyTrail.id,
        segmentId: currentSegment.id,
        challengeId: currentSegment.challenge!.id,
        userAnswer: event.chosenAnswerId,
      ),
    );

    await result.fold(
      (failure) async =>
          emit(StoryPlayerError(failure.message, currentState.storyTrail.id)),
      (updatedProgress) async {
        await _advanceToNextSegment(
          emit,
          currentState.storyTrail,
          updatedProgress,
        );
      },
    );
  }

  /// Handles advancing the story after a narration segment is complete.
  Future<void> _onNarrationFinished(
    NarrationFinished event,
    Emitter<StoryPlayerState> emit,
  ) async {
    final currentState = state;
    if (currentState is! StoryPlayerDisplay) return;

    await _advanceToNextSegment(
      emit,
      currentState.storyTrail,
      currentState.progress,
    );
  }

  /// A shared helper method to advance the story to the next segment or finish it.
  Future<void> _advanceToNextSegment(
    Emitter<StoryPlayerState> emit,
    StoryTrail trail,
    StoryProgress currentProgress,
  ) async {
    final nextIndex = currentProgress.currentSegmentIndex + 1;

    // Check if the story is finished
    if (nextIndex >= trail.segments.length) {
      await markStoryTrailCompletedUseCase(
        MarkStoryTrailCompletedParams(trailId: trail.id),
      );
      emit(StoryPlayerFinished(finalProgress: currentProgress));
    } else {
      // If not finished, create a new progress object with the updated index
      final newProgress = (currentProgress as StoryProgressModel).copyWith(
        currentSegmentIndex: nextIndex,
      );

      // Save the updated progress
      await saveUserStoryProgressUseCase(
        SaveUserStoryProgressParams(progress: newProgress),
      );

      // Emit the display state for the new segment
      // This works because `newProgress` is a new object, so Equatable detects the change.
      emit(StoryPlayerDisplay(storyTrail: trail, progress: newProgress));
    }
  }
}
