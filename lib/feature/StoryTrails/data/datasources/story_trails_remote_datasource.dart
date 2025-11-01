import '../models/story_trail_model.dart';

abstract class StoryTrailsRemoteDataSource {
  /// Fetches a list of [StoryTrailModel] for a given [level] from the remote API.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<List<StoryTrailModel>> getStoryTrailsForLevel(int level);

  /// Fetches a single [StoryTrailModel] by its [trailId] from the remote API.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<StoryTrailModel> getStoryTrailById(String trailId);

  // Future<void> syncUserProgress(StoryProgressModel progress); // Example for later
  // Future<void> syncUserLearningProfile(UserLearningProfileModel profile); // Example for later
}
