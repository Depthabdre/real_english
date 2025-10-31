import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/user_learning_profile.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

class GetUserLearningProfile {
  final StoryTrailsRepository repository;

  GetUserLearningProfile(this.repository);

  Future<Either<Failures, UserLearningProfile>> call() async {
    return await repository.getUserLearningProfile();
  }
}

// No params needed for fetching the current user's profile, assuming it's implicit
class GetUserLearningProfileParams extends Equatable {
  const GetUserLearningProfileParams(); // Or make it empty/omit if no params

  @override
  List<Object?> get props => [];
}
