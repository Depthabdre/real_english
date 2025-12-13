import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/immersion_repository.dart';

class ToggleSaveVideo {
  final ImmersionRepository repository;

  ToggleSaveVideo(this.repository);

  Future<Either<Failures, bool>> call(ToggleSaveVideoParams params) async {
    return await repository.toggleSaveVideo(params.shortId);
  }
}

class ToggleSaveVideoParams extends Equatable {
  final String shortId;

  const ToggleSaveVideoParams({required this.shortId});

  @override
  List<Object?> get props => [shortId];
}
