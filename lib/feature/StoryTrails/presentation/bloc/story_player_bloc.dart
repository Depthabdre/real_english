import 'dart:async';
// Removed: import 'dart:typed_data'; (No longer needed)
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/story_progress_model.dart';
import '../../domain/entities/story_progress.dart';
import '../../domain/entities/story_segment.dart';
import '../../domain/entities/story_trails.dart';
import '../../domain/usecases/get_audio_for_segment.dart';
import '../../domain/usecases/get_story_trail_by_id.dart';
import '../../domain/usecases/get_user_story_progress.dart';
import '../../domain/usecases/mark_story_trail_completed.dart';
import '../../domain/usecases/save_user_story_progress.dart';
import '../../domain/usecases/submit_challenge_answer.dart';

part 'story_player_event.dart';
part 'story_player_state.dart';

class StoryPlayerBloc extends Bloc<StoryPlayerEvent, StoryPlayerState> {
  final GetAudioForSegment getAudioForSegmentUseCase;
  final GetStoryTrailById getStoryTrailByIdUseCase;
  final GetUserStoryProgress getUserStoryProgressUseCase;
  final SubmitChallengeAnswer submitChallengeAnswerUseCase;
  final SaveUserStoryProgress saveUserStoryProgressUseCase;
  final MarkStoryTrailCompleted markStoryTrailCompletedUseCase;

  final AudioPlayer _audioPlayer;
  StreamSubscription? _playerStateSubscription;

  StoryPlayerBloc({
    required this.getAudioForSegmentUseCase,
    required this.getStoryTrailByIdUseCase,
    required this.getUserStoryProgressUseCase,
    required this.submitChallengeAnswerUseCase,
    required this.saveUserStoryProgressUseCase,
    required this.markStoryTrailCompletedUseCase,
  }) : _audioPlayer = AudioPlayer(),
       super(StoryPlayerInitial()) {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        add(NarrationFinished());
      }
    });

    on<StartStory>(_onStartStory);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<NarrationFinished>(_onNarrationFinished);
    on<_AudioPreloaded>(_onAudioPreloaded);
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }

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
        progressResult.fold(
          (failure) => emit(StoryPlayerError(failure.message, event.trailId)),
          (progress) async {
            emit(StoryPlayerDisplay(storyTrail: trail, progress: progress));
            await _playSegmentAndPreloadNext(emit, trail, progress);
          },
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
        final lastAttempt =
            updatedProgress.challengeAttempts[currentSegment.challenge!.id];

        if (lastAttempt?.feedbackMessage?.isNotEmpty ?? false) {
          emit(
            AnswerFeedback(
              isCorrect: lastAttempt!.isCorrect,
              feedbackMessage: lastAttempt.feedbackMessage!,
              displayState: currentState.copyWith(progress: updatedProgress),
            ),
          );
          await Future.delayed(const Duration(seconds: 2));
        }

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
    if (currentState is! StoryPlayerDisplay && currentState is! AnswerFeedback)
      return;

    final displayState = currentState is StoryPlayerDisplay
        ? currentState
        : (currentState as AnswerFeedback).displayState;
    await _advanceToNextSegment(
      emit,
      displayState.storyTrail,
      displayState.progress,
    );
  }

  Future<void> _advanceToNextSegment(
    Emitter<StoryPlayerState> emit,
    StoryTrail trail,
    StoryProgress currentProgress,
  ) async {
    final nextIndex = currentProgress.currentSegmentIndex + 1;

    if (nextIndex >= trail.segments.length) {
      final result = await markStoryTrailCompletedUseCase(
        MarkStoryTrailCompletedParams(trailId: trail.id),
      );
      result.fold(
        (failure) => emit(StoryPlayerError(failure.message, trail.id)),
        (status) {
          if (status.didLevelUp) {
            emit(LevelCompleted(newLevel: status.newLevel));
          } else {
            emit(StoryPlayerFinished(finalProgress: currentProgress));
          }
        },
      );
    } else {
      final newProgress = (currentProgress as StoryProgressModel).copyWith(
        currentSegmentIndex: nextIndex,
      );
      await saveUserStoryProgressUseCase(
        SaveUserStoryProgressParams(progress: newProgress),
      );

      final currentState = state is StoryPlayerDisplay
          ? (state as StoryPlayerDisplay)
          : (state as AnswerFeedback).displayState;

      emit(currentState.copyWith(progress: newProgress));

      await _playSegmentAndPreloadNext(emit, trail, newProgress);
    }
  }

  void _onAudioPreloaded(
    _AudioPreloaded event,
    Emitter<StoryPlayerState> emit,
  ) {
    if (state is StoryPlayerDisplay) {
      final currentState = state as StoryPlayerDisplay;
      // Update cache with String URL
      final newCache = Map<String, String>.from(currentState.audioCache);
      newCache[event.segmentId] = event.audioUrl;
      emit(currentState.copyWith(audioCache: newCache));
    }
  }

  Future<void> _playSegmentAndPreloadNext(
    Emitter<StoryPlayerState> emit,
    StoryTrail trail,
    StoryProgress progress,
  ) async {
    if (state is! StoryPlayerDisplay) return;
    final currentState = state as StoryPlayerDisplay;
    final currentSegment = trail.segments[progress.currentSegmentIndex];

    if (currentSegment.type == SegmentType.narration) {
      // 1. Check cache for URL
      String? audioUrl = currentState.audioCache[currentSegment.id];

      // 2. Fetch if not in cache
      if (audioUrl == null) {
        // Construct API endpoint if missing from model (Legacy Support)
        final apiEndpoint =
            currentSegment.audioEndpoint ??
            '/api/story-trails/segments/${currentSegment.id}/audio';

        final result = await getAudioForSegmentUseCase(
          GetAudioForSegmentParams(audioEndpoint: apiEndpoint),
        );

        await result.fold(
          (failure) async {
            print("Audio fetch failed: ${failure.message}");
          },
          (url) async {
            // Success: 'url' is the OBS link or API link
            audioUrl = url;
            add(_AudioPreloaded(segmentId: currentSegment.id, audioUrl: url));
          },
        );
      }

      // 3. Play URL (Stream)
      if (audioUrl != null) {
        print("🔍 DEBUG: Trying to play URL: $audioUrl"); // <--- ADD THIS
        try {
          // KEY CHANGE: Stream directly from URL
          await _audioPlayer.setUrl(audioUrl!);
          _audioPlayer.play();
        } catch (e) {
          print("Audio playback error: $e");
        }
      }
    }

    // --- PRELOAD NEXT SEGMENT ---
    final preloadIndex = progress.currentSegmentIndex + 1;
    if (preloadIndex < trail.segments.length) {
      final nextSegment = trail.segments[preloadIndex];

      if (nextSegment.type == SegmentType.narration &&
          currentState.audioCache[nextSegment.id] == null) {
        final nextEndpoint =
            nextSegment.audioEndpoint ??
            '/api/story-trails/segments/${nextSegment.id}/audio';

        getAudioForSegmentUseCase(
          GetAudioForSegmentParams(audioEndpoint: nextEndpoint),
        ).then((result) {
          result.fold(
            (failure) => print("Audio preload failed: ${failure.message}"),
            (url) =>
                add(_AudioPreloaded(segmentId: nextSegment.id, audioUrl: url)),
          );
        });
      }
    }
  }
}
