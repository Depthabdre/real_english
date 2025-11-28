
import 'package:dartz/dartz.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/level_completion_status.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';

import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';

import '../../domain/entities/single_choice_challenge.dart';
import '../../domain/entities/story_progress.dart';

import '../../domain/entities/user_learning_profile.dart';
import '../../domain/repositories/story_trails_repository.dart';

import '../datasources/story_trails_local_datasource.dart';
import '../datasources/story_trails_remote_datasource.dart';
import '../models/challenge_attempt_model.dart';
import '../models/story_progress_model.dart';
import '../models/user_learning_profile_model.dart';

class StoryTrailsRepositoryImpl implements StoryTrailsRepository {
  final StoryTrailsRemoteDataSource remoteDataSource;
  final StoryTrailsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  StoryTrailsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, StoryTrail?>> getStoryTrailForLevel(int level) async {
    // Strategy: If online, fetch from remote to get the latest story.
    // If offline, fall back to the local cache's logic to find the next available story.
    if (await networkInfo.isConnected) {
      try {
        final remoteTrail = await remoteDataSource.getStoryTrailForLevel(level);
        // If a new story is fetched, cache it for offline use.
        if (remoteTrail != null) {
          await localDataSource.cacheStoryTrail(remoteTrail);
        }
        return Right(remoteTrail);
      } on ServerException catch (e) {
        // If the server fails, we can still try to get a story from the local cache.
        try {
          final localTrail = await localDataSource.getCachedStoryTrailForLevel(
            level,
          );
          return Right(localTrail);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      }
    } else {
      // Offline: Directly fetch from the local cache.
      try {
        final localTrail = await localDataSource.getCachedStoryTrailForLevel(
          level,
        );
        return Right(localTrail);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failures, StoryTrail>> getStoryTrailById(String trailId) async {
    // This logic remains largely the same, prioritizing remote if online.
    if (await networkInfo.isConnected) {
      try {
        final remoteTrail = await remoteDataSource.getStoryTrailById(trailId);
        await localDataSource.cacheStoryTrail(remoteTrail);
        return Right(remoteTrail);
      } on ServerException catch (e) {
        try {
          final localTrail = await localDataSource.getCachedStoryTrailById(
            trailId,
          );
          if (localTrail != null) return Right(localTrail);
          return Left(ServerFailure(message: e.message));
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      }
    } else {
      try {
        final localTrail = await localDataSource.getCachedStoryTrailById(
          trailId,
        );
        if (localTrail != null) return Right(localTrail);
        return Left(
          CacheFailure(
            message:
                'No cached story with ID $trailId and no internet connection.',
          ),
        );
      } on CacheException {
        return Left(
          CacheFailure(message: 'Could not retrieve story with ID $trailId.'),
        );
      }
    }
  }

  @override
  Future<Either<Failures, StoryProgress>> getUserStoryProgress(
    String trailId,
  ) async {
    try {
      final localProgress = await localDataSource.getCachedUserStoryProgress(
        trailId,
      );
      return Right(localProgress ?? StoryProgressModel(storyTrailId: trailId));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, void>> saveUserStoryProgress(
    StoryProgress progress,
  ) async {
    try {
      final progressModel = progress is StoryProgressModel
          ? progress
          : StoryProgressModel(
              storyTrailId: progress.storyTrailId,
              currentSegmentIndex: progress.currentSegmentIndex,
              modelChallengeAttempts: progress.challengeAttempts.map(
                (key, value) => MapEntry(key, value as ChallengeAttemptModel),
              ),
              isCompleted: progress.isCompleted,
              completionDate: progress.completionDate,
              xpEarned: progress.xpEarned,
            );
      await localDataSource.cacheUserStoryProgress(progressModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, StoryProgress>> submitChallengeAnswer({
    required String trailId,
    required String segmentId,
    required String challengeId,
    required String userAnswer,
  }) async {
    try {
      final trailEither = await getStoryTrailById(trailId);
      return await trailEither.fold((failure) => Left(failure), (
        storyTrail,
      ) async {
        final currentProgressEither = await getUserStoryProgress(trailId);
        return await currentProgressEither.fold((failure) => Left(failure), (
          currentProgress,
        ) async {
          final currentProgressModel = currentProgress as StoryProgressModel;
          final segment = storyTrail.segments.firstWhere(
            (s) => s.id == segmentId,
          );
          final challenge = segment.challenge!;

          bool isCorrect = false;
          String? feedbackMessage;

          if (challenge is SingleChoiceChallenge) {
            isCorrect = challenge.correctAnswerId == userAnswer;
            feedbackMessage = isCorrect
                ? challenge.correctFeedback
                : challenge.incorrectFeedback;
          }

          final newAttempt = ChallengeAttemptModel(
            challengeId: challengeId,
            userAnswer: userAnswer,
            isCorrect: isCorrect,
            attemptDate: DateTime.now(),
            feedbackMessage: feedbackMessage,
          );

          final updatedAttempts = Map<String, ChallengeAttemptModel>.from(
            currentProgressModel.modelChallengeAttempts,
          );
          updatedAttempts[challengeId] = newAttempt;

          final updatedProgress = currentProgressModel.copyWith(
            challengeAttempts: updatedAttempts,
            xpEarned: isCorrect
                ? currentProgressModel.xpEarned + 10
                : currentProgressModel.xpEarned,
          );

          await localDataSource.cacheUserStoryProgress(updatedProgress);
          return Right(updatedProgress);
        });
      });
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on StateError {
      return Left(
        UnknownFailure(
          message: 'Error: Could not find the specified challenge or segment.',
        ),
      );
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, LevelCompletionStatus>> markStoryTrailCompleted(
    String trailId,
  ) async {
    // This operation now requires an internet connection.
    if (await networkInfo.isConnected) {
      try {
        // Delegate the entire operation to the remote data source.
        // The backend now handles all the logic.
        final levelStatus = await remoteDataSource.markStoryTrailCompleted(
          trailId,
        );

        // Optional: Update local progress and profile based on the successful remote call.
        // This is good for keeping the local cache in sync.
        final progressEither = await getUserStoryProgress(trailId);
        progressEither.fold(
          (_) => null, // Silently fail if progress can't be fetched
          (progress) {
            final updatedProgress = (progress as StoryProgressModel).copyWith(
              isCompleted: true,
              completionDate: DateTime.now(),
            );
            localDataSource.cacheUserStoryProgress(updatedProgress);
          },
        );

        // Return the status received directly from the server.
        return Right(levelStatus);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // If offline, we cannot complete the story. Return a failure.
      return Left(
        ServerFailure(message: 'You must be online to complete a story.'),
      );
    }
  }

  @override
  Future<Either<Failures, String>> getAudioForSegment(
    String audioEndpoint,
  ) async {
    try {
      final result = await remoteDataSource.getAudioForSegment(audioEndpoint);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, UserLearningProfile>> getUserLearningProfile() async {
    try {
      final localProfile = await localDataSource.getCachedUserLearningProfile();

      if (localProfile != null) {
        // If a profile exists in the cache, return it.
        return Right(localProfile);
      } else {
        // If the cache is empty (new user), create and return a complete, default profile.
        // This is our "dummy" data for a fresh start.
        print("🔹 No cached profile found. Creating a default profile.");

        // TODO: In a real app, this ID should be fetched from your authentication state
        // (e.g., from the currently logged-in user).
        const defaultUserId = 'new_user_placeholder_id';

        final defaultProfile = UserLearningProfileModel(
          userId: defaultUserId,
          currentLearningLevel: 1, // All users start at level 1
          xpGlobal: 0, // All users start with 0 XP
          completedTrailIds: [], // All users start with no completed trails
        );

        // Optionally, cache this new default profile right away
        await localDataSource.cacheUserLearningProfile(defaultProfile);

        return Right(defaultProfile);
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, void>> updateUserLearningProfile(
    UserLearningProfile profile,
  ) async {
    try {
      // This logic is already correct. It ensures we always cache a Model.
      final profileModel = profile is UserLearningProfileModel
          ? profile
          : UserLearningProfileModel(
              userId: profile.userId,
              currentLearningLevel: profile.currentLearningLevel,
              xpGlobal: profile.xpGlobal,
              completedTrailIds: profile.completedTrailIds,
            );
      await localDataSource.cacheUserLearningProfile(profileModel);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }
}
