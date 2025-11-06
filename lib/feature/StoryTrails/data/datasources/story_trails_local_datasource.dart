import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/exception.dart';
import '../models/story_trail_model.dart';
import '../models/story_progress_model.dart';
import '../models/user_learning_profile_model.dart';

// --- ABSTRACT CLASS DEFINITION (Updated) ---
abstract class StoryTrailsLocalDataSource {
  /// Gets the next available cached [StoryTrailModel] for a specific [level].
  /// Returns null if all stories for the level are complete.
  Future<StoryTrailModel?> getCachedStoryTrailForLevel(int level);

  /// Caches a list of [StoryTrailModel].
  Future<void> cacheStoryTrails(List<StoryTrailModel> trails);

  /// Gets a single cached [StoryTrailModel] by its [trailId].
  Future<StoryTrailModel?> getCachedStoryTrailById(String trailId);

  /// Caches a single [StoryTrailModel].
  Future<void> cacheStoryTrail(StoryTrailModel trail);

  /// Gets the cached [StoryProgressModel] for a specific [trailId].
  Future<StoryProgressModel?> getCachedUserStoryProgress(String trailId);

  /// Caches a [StoryProgressModel].
  Future<void> cacheUserStoryProgress(StoryProgressModel progress);

  /// Gets the cached [UserLearningProfileModel].
  Future<UserLearningProfileModel?> getCachedUserLearningProfile();

  /// Caches a [UserLearningProfileModel].
  Future<void> cacheUserLearningProfile(UserLearningProfileModel profile);
}

// --- HIVE IMPLEMENTATION (Updated) ---
class StoryTrailsLocalDataSourceImpl implements StoryTrailsLocalDataSource {
  static const String _storyTrailsBoxName = 'story_trails_box';
  static const String _storyProgressBoxName = 'story_progress_box';
  static const String _userProfileBoxName = 'user_profile_box';
  static const String _userProfileKey = 'current_user_profile';

  @override
  Future<StoryTrailModel?> getCachedStoryTrailForLevel(int level) async {
    try {
      // 1. Get the user's completed stories to know what to filter out.
      final profileBox = await Hive.openBox<UserLearningProfileModel>(
        _userProfileBoxName,
      );
      final profile = profileBox.get(_userProfileKey);
      final completedTrailIds =
          profile?.completedTrailIds.toSet() ?? <String>{};

      // 2. Search for the next available story.
      final trailsBox = await Hive.openBox<StoryTrailModel>(
        _storyTrailsBoxName,
      );

      // Using a try-catch block is a safe way to handle firstWhere failing
      try {
        final nextTrail = trailsBox.values.firstWhere(
          (trail) =>
              trail.difficultyLevel == level &&
              !completedTrailIds.contains(trail.id),
        );
        return nextTrail;
      } on StateError {
        // This error is thrown by firstWhere if no element is found.
        // This is the expected outcome when a level is complete.
        return null;
      }
    } catch (e) {
      throw CacheException(
        message: 'Failed to retrieve next cached trail: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cacheStoryTrails(List<StoryTrailModel> trails) async {
    try {
      final box = await Hive.openBox<StoryTrailModel>(_storyTrailsBoxName);
      final Map<String, StoryTrailModel> trailsMap = {
        for (var trail in trails) trail.id: trail,
      };
      await box.putAll(trailsMap);
    } catch (e) {
      throw CacheException(
        message: 'Failed to cache story trails: ${e.toString()}',
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
