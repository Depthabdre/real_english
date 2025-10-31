import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/user_learning_profile.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

class UpdateUserLearningProfile {
  final StoryTrailsRepository repository;

  UpdateUserLearningProfile(this.repository);

  Future<Either<Failures, void>> call(
    UpdateUserLearningProfileParams params,
  ) async {
    return await repository.updateUserLearningProfile(params.profile);
  }
}

class UpdateUserLearningProfileParams extends Equatable {
  final UserLearningProfile profile;

  const UpdateUserLearningProfileParams({required this.profile});

  @override
  List<Object?> get props => [profile];
}
