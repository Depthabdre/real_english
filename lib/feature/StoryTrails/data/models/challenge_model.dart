import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';
import 'single_choice_challenge_model.dart';

abstract class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.prompt,
    required super.type,
  });

  Map<String, dynamic> toJson();

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    // FIX: Safer Type Extraction
    // 1. Get the string from 'challenge_type' OR 'type'
    final typeString =
        (json['challenge_type'] ?? json['type'] as String? ?? '');

    // 2. Find the Enum (Case Insensitive) with a Fallback
    final challengeType = ChallengeType.values.firstWhere(
      (e) => e.name.toLowerCase() == typeString.toLowerCase(),
      // Fallback prevents the "Bad state: No element" crash if the backend sends something unexpected
      orElse: () => ChallengeType.singleChoice,
    );

    switch (challengeType) {
      case ChallengeType.singleChoice:
        return SingleChoiceChallengeModel.fromJson(json);
      // Add cases for other challenge types here
      default:
        // Because of the orElse above, this might not be reached,
        // but it's good practice to keep the switch robust.
        return SingleChoiceChallengeModel.fromJson(json);
    }
  }
}
