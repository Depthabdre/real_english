import 'package:real_english/feature/StoryTrails/domain/entities/challenge_attempt.dart';
import 'package:hive/hive.dart';

part 'challenge_attempt_model.g.dart';

@HiveType(typeId: 7) // Unique ID for ChallengeAttemptModel
class ChallengeAttemptModel extends ChallengeAttempt {
  const ChallengeAttemptModel({
    required super.challengeId,
    required super.userAnswer,
    required super.isCorrect,
    required super.attemptDate,
    super.feedbackMessage,
  });

  factory ChallengeAttemptModel.fromJson(Map<String, dynamic> json) {
    return ChallengeAttemptModel(
      challengeId: json['challenge_id'] as String,
      userAnswer: json['user_answer'] as String,
      isCorrect: json['is_correct'] as bool,
      attemptDate: DateTime.parse(json['attempt_date'] as String),
      feedbackMessage: json['feedback_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'user_answer': userAnswer,
      'is_correct': isCorrect,
      'attempt_date': attemptDate.toIso8601String(),
      'feedback_message': feedbackMessage,
    };
  }

  @override
  @HiveField(0)
  String get challengeId => super.challengeId;

  @override
  @HiveField(1)
  String get userAnswer => super.userAnswer;

  @override
  @HiveField(2)
  bool get isCorrect => super.isCorrect;

  @override
  @HiveField(3)
  DateTime get attemptDate => super.attemptDate;

  @override
  @HiveField(4)
  String? get feedbackMessage => super.feedbackMessage;
}
