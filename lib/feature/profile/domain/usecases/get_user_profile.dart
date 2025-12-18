import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetUserProfile {
  final ProfileRepository repository;

  GetUserProfile(this.repository);

  // We use a simple call method, no generic inheritance
  Future<Either<Failures, UserProfile>> call(
    GetUserProfileParams params,
  ) async {
    return await repository.getUserProfile();
  }
}

// Even though we have no params, we keep the pattern consistent
class GetUserProfileParams extends Equatable {
  const GetUserProfileParams();

  @override
  List<Object?> get props => [];
}
