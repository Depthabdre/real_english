import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_datasource.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final ProfileLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, UserProfile>> getUserProfile() async {
    // 1. Check Local Cache FIRST
    try {
      final localProfile = await localDataSource.getLastUserProfile();
      // We have a cached profile! Return it IMMEDIATELY.
      // This makes the UI load super fast.
      return Right(localProfile);
    } on CacheException {
      // 2. No Cache? That's OK. Carry on...
      print("No local profile. Fetching from remote...");
    }

    // 3. Check Network Connection
    if (await networkInfo.isConnected) {
      try {
        // 4. Online? Fetch fresh data and update the cache.
        final remoteProfile = await remoteDataSource.getUserProfile();
        await localDataSource.cacheUserProfile(remoteProfile);
        return Right(remoteProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // 5. Offline and no cache? We have nothing to show :(
      return Left(CacheFailure(message: "No internet and no cached profile."));
    }
  }

  @override
  Future<Either<Failures, UserProfile>> updateProfileIdentity({
    String? fullName,
    File? imageFile,
  }) async {
    // We need internet to update the profile.
    if (await networkInfo.isConnected) {
      try {
        // 1. Send update to server and get the updated profile
        final updatedProfile = await remoteDataSource.updateProfile(
          fullName: fullName,
          imageFile: imageFile,
        );

        // 2. Cache the new version immediately
        await localDataSource.cacheUserProfile(updatedProfile);
        return Right(updatedProfile);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(
        ServerFailure(message: "You must be online to update your profile."),
      );
    }
  }
}
