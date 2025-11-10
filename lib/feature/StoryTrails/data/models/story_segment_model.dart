import 'package:real_english/feature/StoryTrails/data/models/challenge_model.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';

import 'package:hive/hive.dart';

part 'story_segment_model.g.dart';

@HiveType(typeId: 1)
class StorySegmentModel extends StorySegment {
  const StorySegmentModel({
    required super.id,
    required super.type,
    required super.textContent,
    super.imageUrl,
    super.challenge,
  });

  factory StorySegmentModel.fromJson(Map<String, dynamic> json) {
    // This is the logic to parse the nested challenge object.
    Challenge? challengeModel;
    if (json['challenge'] != null) {
      // The ChallengeModel.fromJson factory correctly determines which
      // concrete challenge model to create (e.g., SingleChoiceChallengeModel).
      challengeModel = ChallengeModel.fromJson(
        json['challenge'] as Map<String, dynamic>,
      );
    }

    return StorySegmentModel(
      id: json['id'] as String,
      type: SegmentType.values.firstWhere((e) => e.name == json['type']),
      textContent: json['text_content'] as String,
      imageUrl: json['image_url'] as String?,
      // CORRECT: Pass the 'challengeModel' variable that holds the parsed object.
      challenge: challengeModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'text_content': textContent, // --- REMOVED audio_url ---
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
  @HiveField(2) // --- UPDATED HIVEFIELD INDEX ---
  String get textContent => super.textContent;

  @override
  @HiveField(3) // --- UPDATED HIVEFIELD INDEX ---
  String? get imageUrl => super.imageUrl;

  @override
  @HiveField(4) // --- UPDATED HIVEFIELD INDEX ---
  Challenge? get challenge => super.challenge;
}
