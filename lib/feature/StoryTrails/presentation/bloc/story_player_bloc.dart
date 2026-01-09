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
  final Map<String, Future<String>> _activeDownloads = {};

  StoryPlayerBloc({
    required this.getAudioForSegmentUseCase,
    required this.getStoryTrailByIdUseCase,
    required this.getUserStoryProgressUseCase,
    required this.submitChallengeAnswerUseCase,
    required this.saveUserStoryProgressUseCase,
    required this.markStoryTrailCompletedUseCase,
  }) : _audioPlayer = AudioPlayer(),
       super(StoryPlayerInitial()) {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      // FIX: Only trigger finish if we are completed AND we actually played something.
      // This prevents the player from auto-skipping when it first initializes or loads a URL.
      if (playerState.processingState == ProcessingState.completed &&
          _audioPlayer.position.inMilliseconds > 100) {
        add(NarrationFinished());
      }
    });

    on<StartStory>(_onStartStory);
    on<SubmitAnswer>(_onSubmitAnswer);
    on<NarrationFinished>(_onNarrationFinished);
    on<_AudioPreloaded>(_onAudioPreloaded);
    on<ReplayAudio>(_onReplayAudio);
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

    // 1. Fetch Data
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
            // --- THE FIX IS HERE ---

            // 1. Show the UI IMMEDIATELY (Text + Image)
            emit(StoryPlayerDisplay(storyTrail: trail, progress: progress));

            // 2. THEN start fetching/playing audio in the background
            await _playSegmentAndPreloadNext(emit, trail, progress);
          },
        );
      },
    );
  }

  Future<void> _onReplayAudio(
    ReplayAudio event,
    Emitter<StoryPlayerState> emit,
  ) async {
    if (state is StoryPlayerDisplay) {
      final currentState = state as StoryPlayerDisplay;

      // Briefly reset the playing ID to trigger the UI to reset text
      emit(
        StoryPlayerDisplay(
          storyTrail: currentState.storyTrail,
          progress: currentState.progress,
          audioCache: currentState.audioCache,
          playingSegmentId: null,
        ),
      );

      await _audioPlayer.seek(Duration.zero);
      _audioPlayer.play();

      // Signal UI to start typing again
      emit(
        currentState.copyWith(playingSegmentId: currentState.currentSegment.id),
      );
    }
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
    if (currentState is! StoryPlayerDisplay &&
        currentState is! AnswerFeedback) {
      return;
    }

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
      // 1. Mark Complete in Backend
      final result = await markStoryTrailCompletedUseCase(
        MarkStoryTrailCompletedParams(trailId: trail.id),
      );

      result.fold(
        (failure) => emit(StoryPlayerError(failure.message, trail.id)),
        (status) {
          if (status.didLevelUp) {
            // 2. Emit LevelCompleted with Title
            emit(
              LevelCompleted(
                newLevel: status.newLevel,
                storyTitle: trail.title, // <--- Pass the title here
              ),
            );
          } else {
            // 3. Emit Finished with Title
            emit(
              StoryPlayerFinished(
                finalProgress: currentProgress,
                storyTitle: trail.title, // <--- Pass the title here
              ),
            );
          }
        },
      );
    } else {
      // ... (Rest of the logic for saving progress remains the same)
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

  // 3. UPDATED LOGIC: _playSegmentAndPreloadNext
  Future<void> _playSegmentAndPreloadNext(
    Emitter<StoryPlayerState> emit,
    StoryTrail trail,
    StoryProgress progress,
  ) async {
    if (state is! StoryPlayerDisplay) return;
    final currentState = state as StoryPlayerDisplay;
    final currentSegment = trail.segments[progress.currentSegmentIndex];

    // Reset UI
    final loadingState = currentState.copyWith(
      playingSegmentId: null,
      currentAudioDuration: null,
    );
    emit(loadingState);

    // --- PLAY CURRENT SEGMENT ---
    if (currentSegment.type == SegmentType.narration) {
      String? audioUrl = loadingState.audioCache[currentSegment.id];

      // 1. Fetch if missing (Using our new Smart Helper)
      if (audioUrl == null) {
        try {
          audioUrl = await _fetchOrGetActiveDownload(
            currentSegment.id,
            currentSegment.audioEndpoint,
          );

          // Add to cache event
          if (audioUrl != null) {
            add(
              _AudioPreloaded(segmentId: currentSegment.id, audioUrl: audioUrl),
            );
          }
        } catch (e) {
          print("Audio fetch error: $e");
        }
      }

      // 2. Play
      if (audioUrl != null) {
        try {
          final duration = await _audioPlayer.setUrl(audioUrl);
          _audioPlayer.play();

          emit(
            loadingState.copyWith(
              playingSegmentId: currentSegment.id,
              currentAudioDuration: duration,
              // Ensure cache is updated in state
              audioCache: {
                ...loadingState.audioCache,
                currentSegment.id: audioUrl,
              },
            ),
          );
        } catch (e) {
          emit(loadingState.copyWith(playingSegmentId: currentSegment.id));
        }
      } else {
        emit(loadingState.copyWith(playingSegmentId: currentSegment.id));
      }
    } else {
      emit(loadingState.copyWith(playingSegmentId: currentSegment.id));
    }

    // --- PRELOAD NEXT SEGMENT ---
    final preloadIndex = progress.currentSegmentIndex + 1;
    if (preloadIndex < trail.segments.length) {
      final nextSegment = trail.segments[preloadIndex];

      if (nextSegment.type == SegmentType.narration &&
          currentState.audioCache[nextSegment.id] == null) {
        // Use the same helper! It will add it to _activeDownloads map.
        // We don't await this, we let it run in background.
        _fetchOrGetActiveDownload(nextSegment.id, nextSegment.audioEndpoint)
            .then((url) {
              if (url != null) {
                add(_AudioPreloaded(segmentId: nextSegment.id, audioUrl: url));
              }
            })
            .catchError((_) {}); // Ignore errors in background preload
      }
    }
  }

  // 2. HELPER METHOD: The "Smart" Downloader
  Future<String?> _fetchOrGetActiveDownload(
    String segmentId,
    String? endpoint,
  ) async {
    // Case A: Download is already happening. Join it!
    if (_activeDownloads.containsKey(segmentId)) {
      print("🚀 Joining existing download for $segmentId");
      return _activeDownloads[segmentId];
    }

    // Case B: Start a new download
    final apiEndpoint =
        endpoint ?? '/api/story-trails/segments/$segmentId/audio';

    // Create the future
    final future =
        getAudioForSegmentUseCase(
          GetAudioForSegmentParams(audioEndpoint: apiEndpoint),
        ).then((result) {
          // Clean up map when done (success or fail) so we don't hold old futures
          _activeDownloads.remove(segmentId);

          return result.fold(
            (failure) {
              print("Download failed: ${failure.message}");
              throw failure; // Propagate error
            },
            (url) => url, // Return success URL
          );
        });

    // Store it in the map
    _activeDownloads[segmentId] = future;

    return future;
  }
}
