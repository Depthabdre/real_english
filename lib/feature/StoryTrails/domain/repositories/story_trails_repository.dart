import 'package:dartz/dartz.dart';
import 'package:real_english/core/errors/failures.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_progress.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/user_learning_profile.dart';

abstract class StoryTrailsRepository {
  /// Fetches a list of Story Trails specifically for a given difficulty level.
  /// This will be the primary way to get stories for the user's current level.
  Future<Either<Failures, List<StoryTrail>>> getStoryTrailsForLevel(int level);

  /// Fetches a specific Story Trail by its ID. (Still useful for direct access or internal linking)
  Future<Either<Failures, StoryTrail>> getStoryTrailById(String trailId);

  /// Retrieves the user's current progress for a specific Story Trail.
  Future<Either<Failures, StoryProgress>> getUserStoryProgress(String trailId);

  /// Saves or updates the user's progress for a specific Story Trail.
  Future<Either<Failures, void>> saveUserStoryProgress(StoryProgress progress);

  /// Submits the user's answer to a specific challenge within a Story Trail.
  Future<Either<Failures, StoryProgress>> submitChallengeAnswer({
    required String trailId,
    required String segmentId,
    required String challengeId,
    required String userAnswer,
  });

  /// Marks a specific Story Trail as completed by the user.
  /// This will also update the user's overall learning profile (e.g., add to completed trails, update XP).
  Future<Either<Failures, void>> markStoryTrailCompleted(String trailId);

  // --- New methods for User Learning Profile and Leveling ---

  /// Fetches the user's overall learning profile, including their current level, global XP, etc.
  Future<Either<Failures, UserLearningProfile>> getUserLearningProfile();

  /// Updates the user's overall learning profile.
  /// This will be used when the user's level changes or global XP increases.
  Future<Either<Failures, void>> updateUserLearningProfile(
    UserLearningProfile profile,
  );

  // You might also consider a method to get a "next recommended trail" which uses the level internally.
  // Future<Either<Failures, StoryTrail>> getNextRecommendedStoryTrail(int currentLevel);
}
