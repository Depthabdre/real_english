// Entity to track a user's progress within a specific StoryTrail
import 'package:equatable/equatable.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/challenge_attempt.dart';

class StoryProgress extends Equatable {
  final String storyTrailId;
  final int currentSegmentIndex; // Which segment the user is currently on
  final Map<String, ChallengeAttempt>
  challengeAttempts; // History of attempts for challenges
  final bool isCompleted;
  final DateTime? completionDate;
  final int xpEarned; // For the tree growing / progress metaphor

  const StoryProgress({
    required this.storyTrailId,
    this.currentSegmentIndex = 0,
    this.challengeAttempts = const {},
    this.isCompleted = false,
    this.completionDate,
    this.xpEarned = 0,
  });

  @override
  List<Object?> get props => [
    storyTrailId,
    currentSegmentIndex,
    challengeAttempts,
    isCompleted,
    completionDate,
    xpEarned,
  ];
}
