import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

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

@HiveType(typeId: 3) // Assign unique ID for ChallengeType enum
enum ChallengeType {
  @HiveField(0)
  singleChoice,
  @HiveField(1)
  imageChoice,
  @HiveField(2)
  audioSelection,
  @HiveField(3)
  textInput,
  @HiveField(4)
  speechRecognition,
  @HiveField(5)
  dragAndDrop,
}
