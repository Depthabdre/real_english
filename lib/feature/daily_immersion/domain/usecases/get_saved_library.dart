import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../entities/immersion_short.dart';
import '../repositories/immersion_repository.dart';

class GetSavedLibrary {
  final ImmersionRepository repository;

  GetSavedLibrary(this.repository);

  Future<Either<Failures, List<ImmersionShort>>> call(NoParams params) async {
    return await repository.getSavedLibrary();
  }
}

// If you don't have a shared NoParams in core, you can define it here:
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}
