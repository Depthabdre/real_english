import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

// --- RENAMED CLASS ---
class GetStoryTrailForLevel {
  final StoryTrailsRepository repository;

  GetStoryTrailForLevel(this.repository);

  // --- UPDATED RETURN TYPE ---
  Future<Either<Failures, StoryTrail?>> call(
    GetStoryTrailForLevelParams params,
  ) async {
    return await repository.getStoryTrailForLevel(params.level);
  }
}

class GetStoryTrailForLevelParams extends Equatable {
  final int level;

  const GetStoryTrailForLevelParams({required this.level});

  @override
  List<Object?> get props => [level];
}
