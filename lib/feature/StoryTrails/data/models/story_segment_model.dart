import 'package:hive/hive.dart';
import 'package:real_english/feature/StoryTrails/data/models/challenge_model.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';

part 'story_segment_model.g.dart';

@HiveType(typeId: 1)
class StorySegmentModel extends StorySegment {
  const StorySegmentModel({
    required super.id,
    required super.type,
    required super.textContent,
    super.imageUrl,
    super.audioEndpoint, // Add to constructor
    super.challenge,
  });

  factory StorySegmentModel.fromJson(Map<String, dynamic> json) {
    Challenge? challengeModel;
    if (json['challenge'] != null) {
      challengeModel = ChallengeModel.fromJson(
        json['challenge'] as Map<String, dynamic>,
      );
    }

    return StorySegmentModel(
      id: json['id'] as String,
      type: SegmentType.values.firstWhere((e) => e.name == json['type']),
      textContent: json['text_content'] as String,
      imageUrl: json['image_url'] as String?,
      // --- NEW FIELD PARSING ---
      // The backend sends 'audio_endpoint' in snake_case
      audioEndpoint: json['audio_endpoint'] as String?,
      challenge: challengeModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'text_content': textContent,
      'image_url': imageUrl,
      'audio_endpoint': audioEndpoint, // Add to JSON for serialization
      'challenge': (challenge as ChallengeModel?)?.toJson(),
    };
  }

  // --- UPDATE HIVE FIELDS ---
  @override
  @HiveField(0)
  String get id => super.id;

  @override
  @HiveField(1)
  SegmentType get type => super.type;

  @override
  @HiveField(2)
  String get textContent => super.textContent;

  @override
  @HiveField(3)
  String? get imageUrl => super.imageUrl;

  // --- NEW HIVE FIELD ---
  // We need a new, unique index for our new property.
  @override
  @HiveField(4)
  String? get audioEndpoint => super.audioEndpoint;

  // The challenge field's index needs to be shifted to accommodate the new field.
  @override
  @HiveField(5) // <-- Index was 4, now it is 5
  Challenge? get challenge => super.challenge;
}
