import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
// --- ADD THIS IMPORT ---
import '../entities/level_completion_status.dart';
import '../repositories/story_trails_repository.dart';

class MarkStoryTrailCompleted {
  final StoryTrailsRepository repository;

  MarkStoryTrailCompleted(this.repository);

  // --- UPDATE THE RETURN TYPE HERE ---
  // It no longer returns `void`, but `LevelCompletionStatus`.
  Future<Either<Failures, LevelCompletionStatus>> call(
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
