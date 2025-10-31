import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_progress.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

class SaveUserStoryProgress {
  final StoryTrailsRepository repository;

  SaveUserStoryProgress(this.repository);

  Future<Either<Failures, void>> call(
    SaveUserStoryProgressParams params,
  ) async {
    return await repository.saveUserStoryProgress(params.progress);
  }
}

class SaveUserStoryProgressParams extends Equatable {
  final StoryProgress progress;

  const SaveUserStoryProgressParams({required this.progress});

  @override
  List<Object?> get props => [progress];
}
