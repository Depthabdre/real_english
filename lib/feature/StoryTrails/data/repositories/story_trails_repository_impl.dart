import 'package:dartz/dartz.dart';
import 'package:real_english/core/errors/exception.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/single_choice_challenge.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_progress.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/user_learning_profile.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
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
  Future<Either<Failures, List<StoryTrail>>> getStoryTrailsForLevel(
    int level,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrails = await remoteDataSource.getStoryTrailsForLevel(
          level,
        );
        await localDataSource.cacheStoryTrailsForLevel(level, remoteTrails);
        return Right(remoteTrails);
      } on ServerException catch (e) {
        // If remote fails, try to fall back to cache as a last resort
        try {
          final localTrails = await localDataSource
              .getCachedStoryTrailsForLevel(level);
          return Right(localTrails);
        } on CacheException {
          return Left(
            ServerFailure(message: e.message),
          ); // Return original server error if no cache
        }
      }
    } else {
      // Offline: Directly fetch from local cache
      try {
        final localTrails = await localDataSource.getCachedStoryTrailsForLevel(
          level,
        );
        return Right(localTrails);
      } on CacheException {
        return Left(
          CacheFailure(
            message:
                'No cached stories for level $level and no internet connection.',
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failures, StoryTrail>> getStoryTrailById(String trailId) async {
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
      // If no local progress, return a default/initial progress state
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
      // Ensure we are working with a model instance to cache
      final progressModel = progress is StoryProgressModel
          ? progress
          : StoryProgressModel(
              storyTrailId: progress.storyTrailId,
              currentSegmentIndex: progress.currentSegmentIndex,
              // CORRECT NAME: Use the new parameter name
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
          // We need the model to use copyWith
          final currentProgressModel = currentProgress as StoryProgressModel;

          final segment = storyTrail.segments.firstWhere(
            (s) => s.id == segmentId,
          );
          final challenge = segment.challenge!;
          bool isCorrect = false;

          if (challenge is SingleChoiceChallenge) {
            isCorrect = challenge.correctAnswerId == userAnswer;
          }
          // Add other challenge evaluation logic here

          final newAttempt = ChallengeAttemptModel(
            challengeId: challengeId,
            userAnswer: userAnswer,
            isCorrect: isCorrect,
            attemptDate: DateTime.now(),
          );

          final updatedAttempts = Map<String, ChallengeAttemptModel>.from(
            currentProgressModel.challengeAttempts,
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
  Future<Either<Failures, void>> markStoryTrailCompleted(String trailId) async {
    try {
      final currentProgressEither = await getUserStoryProgress(trailId);
      return await currentProgressEither.fold((failure) => Left(failure), (
        currentProgress,
      ) async {
        final updatedProgress = (currentProgress as StoryProgressModel)
            .copyWith(isCompleted: true, completionDate: DateTime.now());
        await localDataSource.cacheUserStoryProgress(updatedProgress);

        final userProfileEither = await getUserLearningProfile();
        return await userProfileEither.fold((failure) => Left(failure), (
          userProfile,
        ) async {
          final updatedCompletedTrails = List<String>.from(
            userProfile.completedTrailIds,
          );
          if (!updatedCompletedTrails.contains(trailId)) {
            updatedCompletedTrails.add(trailId);
          }

          final updatedProfile = (userProfile as UserLearningProfileModel)
              .copyWith(
                xpGlobal: userProfile.xpGlobal + updatedProgress.xpEarned,
                completedTrailIds: updatedCompletedTrails,
              );
          await localDataSource.cacheUserLearningProfile(updatedProfile);
          return const Right(null);
        });
      });
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failures, UserLearningProfile>> getUserLearningProfile() async {
    try {
      final localProfile = await localDataSource.getCachedUserLearningProfile();
      // TODO: Replace 'default_user_id' with actual user ID from your auth state
      return Right(
        localProfile ?? UserLearningProfileModel(userId: 'default_user_id'),
      );
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failures, void>> updateUserLearningProfile(
    UserLearningProfile profile,
  ) async {
    try {
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
