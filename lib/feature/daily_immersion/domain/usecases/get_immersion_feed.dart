import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/immersion_short.dart';
import '../repositories/immersion_repository.dart';

class GetImmersionFeed {
  final ImmersionRepository repository;

  GetImmersionFeed(this.repository);

  Future<Either<Failures, List<ImmersionShort>>> call(
    GetImmersionFeedParams params,
  ) async {
    return await repository.getFeed(
      category: params.category,
      limit: params.limit,
    );
  }
}

class GetImmersionFeedParams extends Equatable {
  final String category;
  final int limit;

  const GetImmersionFeedParams({this.category = 'mix', this.limit = 10});

  @override
  List<Object?> get props => [category, limit];
}
