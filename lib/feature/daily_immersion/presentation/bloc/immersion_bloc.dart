import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/immersion_short.dart';
import '../../domain/usecases/get_immersion_feed.dart';
import '../../domain/usecases/toggle_save_video.dart';
import '../../domain/usecases/mark_video_watched.dart';

part 'immersion_event.dart';
part 'immersion_state.dart';

class ImmersionBloc extends Bloc<ImmersionEvent, ImmersionState> {
  final GetImmersionFeed getImmersionFeed;
  final ToggleSaveVideo toggleSaveVideo;
  final MarkVideoWatched markVideoWatched;

  ImmersionBloc({
    required this.getImmersionFeed,
    required this.toggleSaveVideo,
    required this.markVideoWatched,
  }) : super(ImmersionInitial()) {
    on<LoadImmersionFeed>(_onLoadFeed);
    on<ToggleSaveShort>(_onToggleSave);
    on<MarkShortAsWatched>(_onMarkWatched);
  }

  Future<void> _onLoadFeed(
    LoadImmersionFeed event,
    Emitter<ImmersionState> emit,
  ) async {
    emit(ImmersionLoading());

    // Call UseCase
    final result = await getImmersionFeed(
      GetImmersionFeedParams(category: event.category),
    );

    result.fold(
      (failure) => emit(ImmersionError(failure.message)),
      (shorts) => emit(
        ImmersionLoaded(shorts: shorts, currentCategory: event.category),
      ),
    );
  }

  Future<void> _onToggleSave(
    ToggleSaveShort event,
    Emitter<ImmersionState> emit,
  ) async {
    // Optimistic Update: Update UI immediately before API returns
    if (state is ImmersionLoaded) {
      final currentState = state as ImmersionLoaded;

      // 1. Find and flip the state in memory
      final updatedShorts = currentState.shorts.map((short) {
        if (short.id == event.shortId) {
          return short.copyWith(isSaved: !short.isSaved);
        }
        return short;
      }).toList();

      // 2. Emit new UI immediately (Fast!)
      emit(currentState.copyWith(shorts: updatedShorts));

      // 3. Call API in background
      final result = await toggleSaveVideo(
        ToggleSaveVideoParams(shortId: event.shortId),
      );

      // 4. Handle failure (Revert if API fails)
      result.fold(
        (failure) {
          // Revert changes if server failed
          final revertedShorts = currentState.shorts.map((short) {
            if (short.id == event.shortId) {
              return short.copyWith(isSaved: !short.isSaved); // Flip back
            }
            return short;
          }).toList();
          emit(currentState.copyWith(shorts: revertedShorts));
          // Optionally show a snackbar error via a side-effect stream
        },
        (newServerState) {
          // Sync with server state (optional, usually matches optimistic state)
        },
      );
    }
  }

  Future<void> _onMarkWatched(
    MarkShortAsWatched event,
    Emitter<ImmersionState> emit,
  ) async {
    // We don't really need to update the UI for "Watched" unless you hide watched videos.
    // This mostly just sends data to the server.
    await markVideoWatched(MarkVideoWatchedParams(shortId: event.shortId));

    // Optional: You could update local state to show a checkmark
    if (state is ImmersionLoaded) {
      final currentState = state as ImmersionLoaded;
      final updatedShorts = currentState.shorts.map((short) {
        if (short.id == event.shortId) {
          return short.copyWith(isWatched: true);
        }
        return short;
      }).toList();
      emit(currentState.copyWith(shorts: updatedShorts));
    }
  }
}
