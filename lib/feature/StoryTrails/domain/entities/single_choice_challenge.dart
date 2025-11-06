import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';

// This is the concrete entity for a multiple-choice scenario
class SingleChoiceChallenge extends Challenge {
  final List<Choice> choices;
  final String correctAnswerId;

  // --- ADD THESE TWO LINES ---
  final String? correctFeedback; // e.g., "Great job! That's right."
  final String?
  incorrectFeedback; // e.g., "Nice try! Let's think about it again."

  const SingleChoiceChallenge({
    required super.id,
    required super.prompt,
    required this.choices,
    required this.correctAnswerId,
    this.correctFeedback, // <--- Add to constructor
    this.incorrectFeedback, // <--- Add to constructor
  }) : super(type: ChallengeType.singleChoice);

  @override
  // --- UPDATE THE PROPS LIST ---
  List<Object?> get props => [
    ...super.props,
    choices,
    correctAnswerId,
    correctFeedback,
    incorrectFeedback,
  ];
}

// Represents a single choice option in a SingleChoiceChallenge
class Choice extends Equatable {
  final String id;
  final String text; // "umbrella", "sunglasses" - This will be used for TTS.
  final String? imageUrl; // Optional icon/image for the choice

  const Choice({required this.id, required this.text, this.imageUrl});

  @override
  // --- UPDATED PROPS LIST ---
  List<Object?> get props => [id, text, imageUrl];
}
