import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/immersion_repository.dart';

class MarkVideoWatched {
  final ImmersionRepository repository;

  MarkVideoWatched(this.repository);

  Future<Either<Failures, void>> call(MarkVideoWatchedParams params) async {
    return await repository.markVideoAsWatched(params.shortId);
  }
}

class MarkVideoWatchedParams extends Equatable {
  final String shortId;

  const MarkVideoWatchedParams({required this.shortId});

  @override
  List<Object?> get props => [shortId];
}
