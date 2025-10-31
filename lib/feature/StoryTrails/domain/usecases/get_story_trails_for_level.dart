import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

class GetStoryTrailsForLevel {
  final StoryTrailsRepository repository;

  GetStoryTrailsForLevel(this.repository);

  Future<Either<Failures, List<StoryTrail>>> call(
    GetStoryTrailsForLevelParams params,
  ) async {
    return await repository.getStoryTrailsForLevel(params.level);
  }
}

class GetStoryTrailsForLevelParams extends Equatable {
  final int level;

  const GetStoryTrailsForLevelParams({required this.level});

  @override
  List<Object?> get props => [level];
}
