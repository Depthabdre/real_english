// Represents a single attempt at a challenge
import 'package:equatable/equatable.dart';

class ChallengeAttempt extends Equatable {
  final String challengeId;
  final String
  userAnswer; // The ID of the chosen answer, or text for text input
  final bool isCorrect;
  final DateTime attemptDate;
  final String?
  feedbackMessage; // e.g., "Oh no! The sun is shining too bright for that!"

  const ChallengeAttempt({
    required this.challengeId,
    required this.userAnswer,
    required this.isCorrect,
    required this.attemptDate,
    this.feedbackMessage,
  });

  @override
  List<Object?> get props => [
    challengeId,
    userAnswer,
    isCorrect,
    attemptDate,
    feedbackMessage,
  ];
}
