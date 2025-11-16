import 'dart:async';
import 'dart:typed_data';
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
      final newCache = Map<String, Uint8List>.from(currentState.audioCache);
      newCache[event.segmentId] = event.audioData;
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
      Uint8List? audioData = currentState.audioCache[currentSegment.id];

      if (audioData == null) {
        final result = await getAudioForSegmentUseCase(
          GetAudioForSegmentParams(
            audioEndpoint: currentSegment.audioEndpoint!,
          ),
        );
        result.fold(
          (failure) => emit(StoryPlayerError(failure.message, trail.id)),
          (data) {
            audioData = data;
            add(_AudioPreloaded(segmentId: currentSegment.id, audioData: data));
          },
        );
      }

      if (audioData != null) {
        try {
          await _audioPlayer.setAudioSource(BytesAudioSource(audioData!));
          _audioPlayer.play();
        } catch (e) {
          emit(StoryPlayerError(e.toString(), trail.id));
        }
      }
    }

    final preloadIndex = progress.currentSegmentIndex + 1;
    if (preloadIndex < trail.segments.length) {
      final nextSegment = trail.segments[preloadIndex];
      if (nextSegment.type == SegmentType.narration &&
          currentState.audioCache[nextSegment.id] == null) {
        getAudioForSegmentUseCase(
          GetAudioForSegmentParams(audioEndpoint: nextSegment.audioEndpoint!),
        ).then((result) {
          result.fold(
            (failure) => print("Audio preload failed: ${failure.message}"),
            (data) => add(
              _AudioPreloaded(segmentId: nextSegment.id, audioData: data),
            ),
          );
        });
      }
    }
  }
}

class BytesAudioSource extends StreamAudioSource {
  final Uint8List _bytes;
  BytesAudioSource(this._bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= _bytes.length;
    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(_bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}
