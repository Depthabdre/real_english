import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'abstract_challenge.g.dart'; // <--- ADD THIS LINE

// Base class for different types of challenges
// ... (rest of the Challenge class is the same)
abstract class Challenge extends Equatable {
  final String id;
  final String prompt;
  final ChallengeType type;

  const Challenge({required this.id, required this.prompt, required this.type});

  @override
  List<Object?> get props => [id, prompt, type];
}

@HiveType(typeId: 3)
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
