import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_progress.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

class GetUserStoryProgress {
  final StoryTrailsRepository repository;

  GetUserStoryProgress(this.repository);

  Future<Either<Failures, StoryProgress>> call(
    GetUserStoryProgressParams params,
  ) async {
    return await repository.getUserStoryProgress(params.trailId);
  }
}

class GetUserStoryProgressParams extends Equatable {
  final String trailId;

  const GetUserStoryProgressParams({required this.trailId});

  @override
  List<Object?> get props => [trailId];
}
