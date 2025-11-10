
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

// It's good practice to import the full path for clarity

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

  Future<void> _onStartStory(
    StartStory event,
    Emitter<StoryPlayerState> emit,
  ) async {
    emit(StoryPlayerLoading());

    final trailResult = await getStoryTrailByIdUseCase(
      GetStoryTrailByIdParams(trailId: event.trailId),
    );

    // Use a clean fold pattern
    await trailResult.fold(
      (failure) async => emit(StoryPlayerError(failure.message, event.trailId)),
      (trail) async {
        final progressResult = await getUserStoryProgressUseCase(
          GetUserStoryProgressParams(trailId: event.trailId),
        );
        progressResult.fold(
          (failure) => emit(StoryPlayerError(failure.message, event.trailId)),
          (progress) =>
              emit(StoryPlayerDisplay(storyTrail: trail, progress: progress)),
        );
      },
    );
  }

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
        // --- 1. HANDLE FEEDBACK ---
        final lastAttempt =
            updatedProgress.challengeAttempts[currentSegment.challenge!.id];

        // Show feedback if it exists
        if (lastAttempt?.feedbackMessage?.isNotEmpty ?? false) {
          emit(
            AnswerFeedback(
              isCorrect: lastAttempt!.isCorrect,
              feedbackMessage: lastAttempt.feedbackMessage!,
              displayState: currentState.copyWith(progress: updatedProgress),
            ),
          );
          // Wait so the user can read the feedback
          await Future.delayed(const Duration(seconds: 2));
        }

        // --- 2. ADVANCE THE STORY ---
        // Ensure we are not in a feedback state before advancing
        if (state is AnswerFeedback || state is StoryPlayerDisplay) {
          await _advanceToNextSegment(
            emit,
            currentState.storyTrail,
            updatedProgress,
          );
        }
      },
    );
  }

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

  Future<void> _advanceToNextSegment(
    Emitter<StoryPlayerState> emit,
    StoryTrail trail,
    StoryProgress currentProgress,
  ) async {
    final nextIndex = currentProgress.currentSegmentIndex + 1;

    if (nextIndex >= trail.segments.length) {
      // --- HANDLE STORY COMPLETION AND LEVEL UP ---
      final result = await markStoryTrailCompletedUseCase(
        MarkStoryTrailCompletedParams(trailId: trail.id),
      );

      result.fold(
        (failure) => emit(StoryPlayerError(failure.message, trail.id)),
        (status) {
          // Check the status returned from the repository
          if (status.didLevelUp) {
            emit(LevelCompleted(newLevel: status.newLevel));
          } else {
            emit(StoryPlayerFinished(finalProgress: currentProgress));
          }
        },
      );
    } else {
      // --- HANDLE ADVANCING TO THE NEXT SEGMENT ---
      final newProgress = (currentProgress as StoryProgressModel).copyWith(
        currentSegmentIndex: nextIndex,
      );

      await saveUserStoryProgressUseCase(
        SaveUserStoryProgressParams(progress: newProgress),
      );

      emit(StoryPlayerDisplay(storyTrail: trail, progress: newProgress));
    }
  }
}

// Extension to add a `copyWith` method to the StoryPlayerDisplay state.
// This is crucial for the feedback logic to work correctly.
extension StoryPlayerDisplayExtension on StoryPlayerDisplay {
  StoryPlayerDisplay copyWith({
    StoryTrail? storyTrail,
    StoryProgress? progress,
  }) {
    return StoryPlayerDisplay(
      storyTrail: storyTrail ?? this.storyTrail,
      progress: progress ?? this.progress,
    );
  }
}
