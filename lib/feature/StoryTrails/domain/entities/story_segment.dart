import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';

part 'story_segment.g.dart'; // <--- ADD THIS LINE

// Represents a sequential part of a story
// ... (rest of the StorySegment class is the same)
class StorySegment extends Equatable {
  final String id;
  final SegmentType type;
  final String audioUrl;
  final String textContent;
  final String? imageUrl;
  final Challenge? challenge;

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

@HiveType(typeId: 2)
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
