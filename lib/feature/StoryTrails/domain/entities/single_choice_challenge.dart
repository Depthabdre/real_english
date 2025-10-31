// Specific challenge entity for multiple-choice scenarios (e.☂️/😎)
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';

class SingleChoiceChallenge extends Challenge {
  final List<Choice> choices;
  final String correctAnswerId; // ID of the correct choice

  const SingleChoiceChallenge({
    required super.id,
    required super.prompt,
    required this.choices,
    required this.correctAnswerId,
  }) : super(type: ChallengeType.singleChoice);

  @override
  List<Object?> get props => [...super.props, choices, correctAnswerId];
}

// Represents a single choice option in a SingleChoiceChallenge
class Choice extends Equatable {
  final String id;
  final String text; // "umbrella", "sunglasses"
  final String? imageUrl; // Optional icon/image for the choice
  final String? audioUrl; // Optional audio for the choice

  const Choice({
    required this.id,
    required this.text,
    this.imageUrl,
    this.audioUrl,
  });

  @override
  List<Object?> get props => [id, text, imageUrl, audioUrl];
}
