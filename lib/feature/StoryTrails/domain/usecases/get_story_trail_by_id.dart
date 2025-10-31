import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

class GetStoryTrailById {
  final StoryTrailsRepository repository;

  GetStoryTrailById(this.repository);

  Future<Either<Failures, StoryTrail>> call(
    GetStoryTrailByIdParams params,
  ) async {
    return await repository.getStoryTrailById(params.trailId);
  }
}

class GetStoryTrailByIdParams extends Equatable {
  final String trailId;

  const GetStoryTrailByIdParams({required this.trailId});

  @override
  List<Object?> get props => [trailId];
}
