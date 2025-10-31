import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_progress.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';

// Represents a single Story Trail, e.g., "A Morning in the Park"
class StoryTrail extends Equatable {
  final String id;
  final String title; // "A Morning in the Park"
  final String description; // "Join Anna on her walk to the park."
  final String imageUrl; // Image for the trail card/intro
  final int difficultyLevel; // This is the key for our level system
  final List<StorySegment> segments; // The sequential parts of the story
  final StoryProgress?
  userProgress; // Optional: User's progress for this specific trail

  const StoryTrail({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.difficultyLevel,
    required this.segments,
    this.userProgress, // User's progress can be null if not started
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    imageUrl,
    difficultyLevel,
    segments,
    userProgress,
  ];
}
