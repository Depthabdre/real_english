import 'package:equatable/equatable.dart';

import 'package:hive/hive.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/abstract_challenge.dart';

part 'story_segment.g.dart';

// Represents a sequential part of a story
class StorySegment extends Equatable {
  final String id;
  final SegmentType type;
  final String textContent; // This will be used for TTS.
  final String? imageUrl;
  final Challenge? challenge;

  const StorySegment({
    required this.id,
    required this.type,
    required this.textContent,
    this.imageUrl,
    this.challenge,
  });

  @override
  // --- UPDATED PROPS LIST ---
  List<Object?> get props => [id, type, textContent, imageUrl, challenge];
}

@HiveType(typeId: 2)
enum SegmentType {
  // ... (enum definition remains the same)
  @HiveField(0)
  narration,
  @HiveField(1)
  choiceChallenge,
  // NOTE: You might consider renaming or removing audioChallenge later
  // if all audio is TTS-based. For now, we can leave it.
  @HiveField(2)
  audioChallenge,
  @HiveField(3)
  speechChallenge,
  @HiveField(4)
  dragDropChallenge,
}
