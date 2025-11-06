import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';

import '../../domain/entities/single_choice_challenge.dart';
import 'challenge_model.dart';
import 'choice_model.dart';
import 'package:hive/hive.dart';

part 'single_choice_challenge_model.g.dart';

@HiveType(typeId: 4)
class SingleChoiceChallengeModel extends SingleChoiceChallenge
    implements ChallengeModel {
  const SingleChoiceChallengeModel({
    required super.id,
    required super.prompt,
    required List<ChoiceModel> choices,
    required super.correctAnswerId,
    super.correctFeedback,
    super.incorrectFeedback,
  }) : super(choices: choices);

  factory SingleChoiceChallengeModel.fromJson(Map<String, dynamic> json) {
    return SingleChoiceChallengeModel(
      id: json['id'] as String,
      prompt: json['prompt'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => ChoiceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      correctAnswerId: json['correct_answer_id'] as String,
      correctFeedback: json['correct_feedback'] as String?,
      incorrectFeedback: json['incorrect_feedback'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prompt': prompt,
      'challenge_type': type.name,
      'choices': (choices as List<ChoiceModel>).map((e) => e.toJson()).toList(),
      'correct_answer_id': correctAnswerId,
      'correct_feedback': correctFeedback,
      'incorrect_feedback': incorrectFeedback,
    };
  }

  // --- FIX: ADD ALL REQUIRED HIVEFIELD OVERRIDES ---

  @override
  @HiveField(0)
  String get id => super.id;

  @override
  @HiveField(1)
  String get prompt => super.prompt;

  @override
  @HiveField(2)
  ChallengeType get type => super.type;

  @override
  @HiveField(3)
  List<Choice> get choices => super.choices;

  @override
  @HiveField(4)
  String get correctAnswerId => super.correctAnswerId;

  @override
  @HiveField(5)
  String? get correctFeedback => super.correctFeedback;

  @override
  @HiveField(6)
  String? get incorrectFeedback => super.incorrectFeedback;
}
