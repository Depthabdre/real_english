import 'package:real_english/feature/StoryTrails/data/models/challenge_model.dart';
import 'package:real_english/feature/StoryTrails/data/models/single_choice_challenge_model.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';


import 'package:hive/hive.dart';

part 'story_segment_model.g.dart';

@HiveType(typeId: 1) // Unique ID for StorySegmentModel
class StorySegmentModel extends StorySegment {
  const StorySegmentModel({
    required super.id,
    required super.type,
    required super.audioUrl,
    required super.textContent,
    super.imageUrl,
    super.challenge,
  });

  factory StorySegmentModel.fromJson(Map<String, dynamic> json) {
    Challenge? challengeModel;
    if (json['challenge'] != null) {
      final challengeJson = json['challenge'] as Map<String, dynamic>;
      final challengeTypeString = challengeJson['challenge_type'] as String;
      final challengeType = ChallengeType.values.firstWhere(
        (e) => e.name == challengeTypeString,
      );

      switch (challengeType) {
        case ChallengeType.singleChoice:
          challengeModel = SingleChoiceChallengeModel.fromJson(challengeJson);
          break;
        // Add cases for other challenge types as they are defined
        default:
          throw Exception('Unknown challenge type: $challengeTypeString');
      }
    }

    return StorySegmentModel(
      id: json['id'] as String,
      type: SegmentType.values.firstWhere((e) => e.name == json['type']),
      audioUrl: json['audio_url'] as String,
      textContent: json['text_content'] as String,
      imageUrl: json['image_url'] as String?,
      challenge: challengeModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'audio_url': audioUrl,
      'text_content': textContent,
      'image_url': imageUrl,
      'challenge': (challenge as ChallengeModel?)?.toJson(),
    };
  }

  @override
  @HiveField(0)
  String get id => super.id;

  @override
  @HiveField(1)
  SegmentType get type => super.type;

  @override
  @HiveField(2)
  String get audioUrl => super.audioUrl;

  @override
  @HiveField(3)
  String get textContent => super.textContent;

  @override
  @HiveField(4)
  String? get imageUrl => super.imageUrl;

  @override
  @HiveField(5)
  Challenge? get challenge => super.challenge;
}
