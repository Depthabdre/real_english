import 'package:dartz/dartz.dart';
import 'package:real_english/core/errors/failures.dart';
import '../entities/immersion_short.dart';

abstract class ImmersionRepository {
  /// Fetches a list of shorts for the infinite feed.
  /// [category] is optional (defaults to 'mix' in backend).
  /// [limit] defines how many videos to fetch at once (pagination).
  Future<Either<Failures, List<ImmersionShort>>> getFeed({
    String category = 'mix',
    int limit = 10,
  });

  /// Toggles the 'saved' status of a video.
  /// Returns [bool] representing the NEW state (true = saved, false = unsaved).
  Future<Either<Failures, bool>> toggleSaveVideo(String shortId);

  /// Marks a video as watched to update analytics/algorithm.
  Future<Either<Failures, void>> markVideoAsWatched(String shortId);

  /// Retrieves the list of videos the user has explicitly saved.
  Future<Either<Failures, List<ImmersionShort>>> getSavedLibrary();
}
