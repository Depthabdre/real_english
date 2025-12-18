import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileIdentity {
  final ProfileRepository repository;

  UpdateProfileIdentity(this.repository);

  Future<Either<Failures, UserProfile>> call(UpdateProfileParams params) async {
    return await repository.updateProfileIdentity(
      fullName: params.fullName,
      imageFile: params.imageFile,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? fullName;
  final File? imageFile;

  const UpdateProfileParams({this.fullName, this.imageFile});

  @override
  List<Object?> get props => [fullName, imageFile];
}
