import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

class MarkStoryTrailCompleted {
  final StoryTrailsRepository repository;

  MarkStoryTrailCompleted(this.repository);

  Future<Either<Failures, void>> call(
    MarkStoryTrailCompletedParams params,
  ) async {
    return await repository.markStoryTrailCompleted(params.trailId);
  }
}

class MarkStoryTrailCompletedParams extends Equatable {
  final String trailId;

  const MarkStoryTrailCompletedParams({required this.trailId});

  @override
  List<Object?> get props => [trailId];
}
