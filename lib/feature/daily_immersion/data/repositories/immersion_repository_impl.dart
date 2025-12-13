import 'package:dartz/dartz.dart';
import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/immersion_short.dart';
import '../../domain/repositories/immersion_repository.dart';
import '../datasources/immersion_remote_datasource.dart';

class ImmersionRepositoryImpl implements ImmersionRepository {
  final ImmersionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ImmersionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failures, List<ImmersionShort>>> getFeed({
    String category = 'mix',
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteShorts = await remoteDataSource.getFeed(
          category: category,
          limit: limit,
        );
        return Right(remoteShorts);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // For MVP, we return a failure if offline.
      // Later you can implement a local cache for "Offline Pack".
      return Left(
        ServerFailure(
          message: 'No internet connection. Please connect to watch shorts.',
        ),
      );
    }
  }

  @override
  Future<Either<Failures, List<ImmersionShort>>> getSavedLibrary() async {
    if (await networkInfo.isConnected) {
      try {
        final savedShorts = await remoteDataSource.getSavedLibrary();
        return Right(savedShorts);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(
        ServerFailure(message: 'Connect to internet to see saved videos.'),
      );
    }
  }

  @override
  Future<Either<Failures, bool>> toggleSaveVideo(String shortId) async {
    if (await networkInfo.isConnected) {
      try {
        final isSaved = await remoteDataSource.toggleSaveVideo(shortId);
        return Right(isSaved);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(ServerFailure(message: 'Action failed. No internet.'));
    }
  }

  @override
  Future<Either<Failures, void>> markVideoAsWatched(String shortId) async {
    // This is fire-and-forget logic, usually shouldn't block UI
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markVideoAsWatched(shortId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      // Silently fail if offline (analytics aren't critical)
      return const Right(null);
    }
  }
}
