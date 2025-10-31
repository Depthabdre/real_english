import 'package:equatable/equatable.dart';

// Base class for different types of challenges
// This allows us to have different challenge structures while keeping a common type
abstract class Challenge extends Equatable {
  final String id;
  final String prompt; // "Should I take my umbrella or my sunglasses?"
  final ChallengeType type; // Enum for the specific challenge type

  const Challenge({required this.id, required this.prompt, required this.type});

  @override
  List<Object?> get props => [id, prompt, type];
}

enum ChallengeType {
  singleChoice,
  imageChoice,
  audioSelection,
  textInput,
  speechRecognition,
  dragAndDrop,
  // ... more as needed
}
