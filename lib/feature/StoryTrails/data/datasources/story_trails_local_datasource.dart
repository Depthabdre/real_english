import '../models/story_trail_model.dart';
import '../models/story_progress_model.dart';
import '../models/user_learning_profile_model.dart';

abstract class StoryTrailsLocalDataSource {
  /// Gets the cached list of [StoryTrailModel] for a specific [level].
  ///
  /// Throws a [CacheException] if no cached data is present.
  Future<List<StoryTrailModel>> getCachedStoryTrailsForLevel(int level);

  /// Caches a list of [StoryTrailModel] for a specific [level].
  Future<void> cacheStoryTrailsForLevel(
    int level,
    List<StoryTrailModel> trails,
  );

  /// Gets a single cached [StoryTrailModel] by its [trailId].
  /// Returns null if not found.
  ///
  /// Throws a [CacheException] on failure.
  Future<StoryTrailModel?> getCachedStoryTrailById(String trailId);

  /// Caches a single [StoryTrailModel].
  Future<void> cacheStoryTrail(StoryTrailModel trail);

  /// Gets the cached [StoryProgressModel] for a specific [trailId].
  /// Returns null if not found.
  ///
  /// Throws a [CacheException] on failure.
  Future<StoryProgressModel?> getCachedUserStoryProgress(String trailId);

  /// Caches a [StoryProgressModel].
  Future<void> cacheUserStoryProgress(StoryProgressModel progress);

  /// Gets the cached [UserLearningProfileModel].
  /// Returns null if not found.
  ///
  /// Throws a [CacheException] on failure.
  Future<UserLearningProfileModel?> getCachedUserLearningProfile();

  /// Caches a [UserLearningProfileModel].
  Future<void> cacheUserLearningProfile(UserLearningProfileModel profile);
}
