import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';

// Represents a sequential part of a story, which can be narration or a challenge
class StorySegment extends Equatable {
  final String id;
  final SegmentType type; // e.g., Narration, ChoiceChallenge, AudioChallenge
  final String audioUrl; // Audio for narration or prompt
  final String textContent; // Text for narration or prompt
  final String? imageUrl; // Optional image for this segment
  final Challenge? challenge; // Optional: If this segment is a challenge

  const StorySegment({
    required this.id,
    required this.type,
    required this.audioUrl,
    required this.textContent,
    this.imageUrl,
    this.challenge,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    audioUrl,
    textContent,
    imageUrl,
    challenge,
  ];
}

// Defines the type of a story segment
@HiveType(typeId: 2) // Assign unique ID for SegmentType enum
enum SegmentType {
  @HiveField(0)
  narration,
  @HiveField(1)
  choiceChallenge,
  @HiveField(2)
  audioChallenge,
  @HiveField(3)
  speechChallenge,
  @HiveField(4)
  dragDropChallenge,
}
