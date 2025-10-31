import 'package:equatable/equatable.dart';
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
enum SegmentType {
  narration, // A segment that just narrates the story
  choiceChallenge, // A segment with a multiple-choice interaction (e.g., umbrella/sunglasses)
  audioChallenge, // A segment that requires listening and interaction (e.g., listen & choose)
  speechChallenge, // A segment that requires speech input (e.g., repeat what you hear)
  dragDropChallenge, // A segment with drag and drop interaction
  // Add other challenge types as we define them
}
