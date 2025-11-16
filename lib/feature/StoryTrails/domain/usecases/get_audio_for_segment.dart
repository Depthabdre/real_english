import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/story_trails_repository.dart';

class GetAudioForSegment {
  final StoryTrailsRepository repository;

  GetAudioForSegment(this.repository);

  Future<Either<Failures, Uint8List>> call(
    GetAudioForSegmentParams params,
  ) async {
    return await repository.getAudioForSegment(params.audioEndpoint);
  }
}

class GetAudioForSegmentParams extends Equatable {
  final String audioEndpoint;

  const GetAudioForSegmentParams({required this.audioEndpoint});

  @override
  List<Object?> get props => [audioEndpoint];
}
