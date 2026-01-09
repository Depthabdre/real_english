import 'package:dartz/dartz.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/level_completion_status.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import 'package:real_english/feature/auth_onboarding/data/datasources/auth_local_datasource.dart';
import 'package:real_english/feature/auth_onboarding/data/models/user_model.dart';

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
  final AuthLocalDatasource authLocalDataSource;

  StoryTrailsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.authLocalDataSource,
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
    if (await networkInfo.isConnected) {
      try {
        // 1. Call Backend
        final levelStatus = await remoteDataSource.markStoryTrailCompleted(
          trailId,
        );

        // 2. Mark Story as Completed in Local Story Cache
        final progressEither = await getUserStoryProgress(trailId);
        progressEither.fold((_) => null, (progress) {
          final updatedProgress = (progress as StoryProgressModel).copyWith(
            isCompleted: true,
            completionDate: DateTime.now(),
          );
          localDataSource.cacheUserStoryProgress(updatedProgress);
        });

        // 3. Update User Profiles (Sync Logic)
        if (levelStatus.didLevelUp) {
          await _syncLevelUpToLocalCaches(levelStatus.newLevel);
        }

        return Right(levelStatus);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(
        ServerFailure(message: 'You must be online to complete a story.'),
      );
    }
  }

  /// Helper to keep both Story Cache and Auth Cache in sync when leveling up
  Future<void> _syncLevelUpToLocalCaches(int newLevel) async {
    try {
      // A. Update Story Learning Profile
      final profileEither = await getUserLearningProfile();
      profileEither.fold((_) => null, (currentProfile) async {
        final updatedProfile = (currentProfile as UserLearningProfileModel)
            .copyWith(currentLearningLevel: newLevel);
        await localDataSource.cacheUserLearningProfile(updatedProfile);
      });

      // B. Update Auth User Cache (CRITICAL FIX)
      // This ensures if the user restarts the app, AuthLocalDatasource has the new level.
      final currentUser = await authLocalDataSource.getLastUser();
      if (currentUser != null) {
        // Create a new UserModel with the updated level
        final updatedUser = UserModel(
          id: currentUser.id,
          fullName: currentUser.fullName,
          email: currentUser.email,
          level: newLevel, // <--- UPDATE LEVEL HERE
        );
        await authLocalDataSource.cacheUser(updatedUser);
        print("✅ Auth Cache Updated to Level $newLevel");
      }
    } catch (e) {
      print("⚠️ Failed to sync local caches: $e");
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
      // 1. Check Local Story Cache (The most specific data)
      final localProfile = await localDataSource.getCachedUserLearningProfile();
      if (localProfile != null) {
        // Optional: Verify this profile belongs to the currently logged-in user
        // to prevent data leaking between users.
        final authUser = await authLocalDataSource.getLastUser();
        if (authUser != null && authUser.id == localProfile.userId) {
          return Right(localProfile);
        }
        // If IDs don't match, we fall through to reload from Auth Cache
      }

      // 2. Fallback: Load from Auth Local Cache (Your requested fix)
      // This works because Login/Signup/GoogleSignIn all save to this cache.
      final authUser = await authLocalDataSource.getLastUser();

      if (authUser != null) {
        print(
          "🔹 Initializing Profile from Auth Cache: Level ${authUser.level}",
        );

        final syncedProfile = UserLearningProfileModel(
          userId: authUser.id,
          currentLearningLevel: authUser.level, // <--- Get level from Auth
          xpGlobal: 0,
          completedTrailIds: [],
        );

        // Save to Story cache so step 1 works next time
        await localDataSource.cacheUserLearningProfile(syncedProfile);
        return Right(syncedProfile);
      }

      // 3. Last Resort: Default
      print("⚠️ No user data found. Defaulting to Level 1.");
      final defaultProfile = const UserLearningProfileModel(
        userId: 'unknown',
        currentLearningLevel: 1,
        xpGlobal: 0,
        completedTrailIds: [],
      );
      return Right(defaultProfile);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, void>> updateUserLearningProfile(
    UserLearningProfile profile,
  ) async {
    try {
      final profileModel = UserLearningProfileModel(
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
