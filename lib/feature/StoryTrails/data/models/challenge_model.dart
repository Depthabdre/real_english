import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';

import 'single_choice_challenge_model.dart'; // Import for dynamic fromJson factory

// No `part` directive here as it's an abstract class

abstract class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.prompt,
    required super.type,
  });

  Map<String, dynamic> toJson();

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    final challengeType = ChallengeType.values.firstWhere(
      (e) => e.name == (json['challenge_type'] ?? json['type']),
    );
    switch (challengeType) {
      case ChallengeType.singleChoice:
        return SingleChoiceChallengeModel.fromJson(json);
      // Add cases for other challenge types here
      default:
        throw Exception('Unknown ChallengeModel type: ${challengeType.name}');
    }
  }

  @override
  String get id => super.id;
  @override
  String get prompt => super.prompt;
  @override
  ChallengeType get type => super.type;
}



