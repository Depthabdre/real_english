import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_progress.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

class SubmitChallengeAnswer {
  final StoryTrailsRepository repository;

  SubmitChallengeAnswer(this.repository);

  Future<Either<Failures, StoryProgress>> call(
    SubmitChallengeAnswerParams params,
  ) async {
    return await repository.submitChallengeAnswer(
      trailId: params.trailId,
      segmentId: params.segmentId,
      challengeId: params.challengeId,
      userAnswer: params.userAnswer,
    );
  }
}

class SubmitChallengeAnswerParams extends Equatable {
  final String trailId;
  final String segmentId;
  final String challengeId;
  final String userAnswer;

  const SubmitChallengeAnswerParams({
    required this.trailId,
    required this.segmentId,
    required this.challengeId,
    required this.userAnswer,
  });

  @override
  List<Object?> get props => [trailId, segmentId, challengeId, userAnswer];
}
