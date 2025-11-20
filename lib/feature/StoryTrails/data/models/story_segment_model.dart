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

      // FIX 1: Safety check for Enum (AI might return "ChoiceChallenge" instead of "choiceChallenge")
      type: SegmentType.values.firstWhere(
        (e) => e.name.toLowerCase() == (json['type'] as String).toLowerCase(),
        orElse: () => SegmentType.narration, // Fallback to prevent crash
      ),

      // FIX 2: Handle camelCase (from Backend Entity) AND snake_case (raw)
      textContent: (json['text_content'] ?? json['textContent']) as String,

      // FIX 3: Handle camelCase AND snake_case
      imageUrl: (json['image_url'] ?? json['imageUrl']) as String?,

      // FIX 4: Handle camelCase AND snake_case
      audioEndpoint:
          (json['audio_endpoint'] ?? json['audioEndpoint']) as String?,

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
