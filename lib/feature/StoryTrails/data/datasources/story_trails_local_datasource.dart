import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/exception.dart';
import '../models/story_trail_model.dart';
import '../models/story_progress_model.dart';
import '../models/user_learning_profile_model.dart';

// --- ABSTRACT CLASS DEFINITION ---
// This is the contract our repository implementation will depend on.

abstract class StoryTrailsLocalDataSource {
  /// Gets the cached list of [StoryTrailModel] for a specific [level].
  /// Throws a [CacheException] if no cached data is present for that level.
  Future<List<StoryTrailModel>> getCachedStoryTrailsForLevel(int level);

  /// Caches a list of [StoryTrailModel]. Each trail is stored individually by its ID for efficient lookup.
  Future<void> cacheStoryTrailsForLevel(
    int level,
    List<StoryTrailModel> trails,
  );

  /// Gets a single cached [StoryTrailModel] by its [trailId].
  /// Returns `null` if the trail is not found in the cache.
  Future<StoryTrailModel?> getCachedStoryTrailById(String trailId);

  /// Caches a single [StoryTrailModel].
  Future<void> cacheStoryTrail(StoryTrailModel trail);

  /// Gets the cached [StoryProgressModel] for a specific [trailId].
  /// Returns `null` if no progress is found.
  Future<StoryProgressModel?> getCachedUserStoryProgress(String trailId);

  /// Caches a [StoryProgressModel].
  Future<void> cacheUserStoryProgress(StoryProgressModel progress);

  /// Gets the cached [UserLearningProfileModel].
  /// Returns `null` if no profile is found.
  Future<UserLearningProfileModel?> getCachedUserLearningProfile();

  /// Caches a [UserLearningProfileModel].
  Future<void> cacheUserLearningProfile(UserLearningProfileModel profile);
}

// --- HIVE IMPLEMENTATION ---

class StoryTrailsLocalDataSourceImpl implements StoryTrailsLocalDataSource {
  // Use Hive directly. Ensure Hive has been initialized in your main.dart
  // and all adapters have been registered.

  // Define constant names for our Hive boxes to avoid magic strings.
  static const String _storyTrailsBoxName = 'story_trails_box';
  static const String _storyProgressBoxName = 'story_progress_box';
  static const String _userProfileBoxName = 'user_profile_box';
  static const String _userProfileKey = 'current_user_profile';

  @override
  Future<void> cacheStoryTrailsForLevel(
    int level,
    List<StoryTrailModel> trails,
  ) async {
    try {
      // We cache trails individually using their ID as the key.
      // This makes lookups by ID very fast and avoids reading/writing a huge list every time.
      final box = await Hive.openBox<StoryTrailModel>(_storyTrailsBoxName);
      final Map<String, StoryTrailModel> trailsMap = {
        for (var trail in trails) trail.id: trail,
      };
      await box.putAll(trailsMap);
    } catch (e) {
      // Handle potential Hive errors
      throw CacheException(
        message: 'Failed to cache story trails: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<StoryTrailModel>> getCachedStoryTrailsForLevel(int level) async {
    try {
      final box = await Hive.openBox<StoryTrailModel>(_storyTrailsBoxName);
      // Read all trails from the box and filter them by the required level in memory.
      final trailsForLevel = box.values
          .where((trail) => trail.difficultyLevel == level)
          .toList();

      if (trailsForLevel.isNotEmpty) {
        return trailsForLevel;
      } else {
        // Throw exception if no trails for that level are found, as per the contract.
        throw CacheException(
          message: 'No cached story trails found for level $level.',
        );
      }
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to retrieve cached trails: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheStoryTrail(StoryTrailModel trail) async {
    try {
      final box = await Hive.openBox<StoryTrailModel>(_storyTrailsBoxName);
      await box.put(trail.id, trail);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache story trail: ${e.toString()}',
      );
    }
  }

  @override
  Future<StoryTrailModel?> getCachedStoryTrailById(String trailId) async {
    try {
      final box = await Hive.openBox<StoryTrailModel>(_storyTrailsBoxName);
      // Hive's get() method is highly optimized for key-based lookups.
      return box.get(trailId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve story trail by ID: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheUserStoryProgress(StoryProgressModel progress) async {
    try {
      final box = await Hive.openBox<StoryProgressModel>(_storyProgressBoxName);
      // Use the storyTrailId as the unique key for its progress.
      await box.put(progress.storyTrailId, progress);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache user progress: ${e.toString()}',
      );
    }
  }

  @override
  Future<StoryProgressModel?> getCachedUserStoryProgress(String trailId) async {
    try {
      final box = await Hive.openBox<StoryProgressModel>(_storyProgressBoxName);
      return box.get(trailId);
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve user progress: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheUserLearningProfile(
    UserLearningProfileModel profile,
  ) async {
    try {
      final box = await Hive.openBox<UserLearningProfileModel>(
        _userProfileBoxName,
      );
      // There's only one user profile, so we use a constant key.
      await box.put(_userProfileKey, profile);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache user profile: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserLearningProfileModel?> getCachedUserLearningProfile() async {
    try {
      final box = await Hive.openBox<UserLearningProfileModel>(
        _userProfileBoxName,
      );
      return box.get(_userProfileKey);
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve user profile: ${e.toString()}',
      );
    }
  }
}
