// We also need a way to track the user's *overall* learning level.
// This could be part of a broader UserProfile entity or a dedicated LearningProfile entity.
// For now, let's assume `User` entity might eventually have a `currentLearningLevel` property.
// Or we introduce a new entity:
import 'package:equatable/equatable.dart';

class UserLearningProfile extends Equatable {
  final String userId;
  final int currentLearningLevel;
  final int xpGlobal; // Total XP earned across all stories
  final List<String> completedTrailIds; // To track which trails are done

  const UserLearningProfile({
    required this.userId,
    this.currentLearningLevel = 1, // Start at level 1
    this.xpGlobal = 0,
    this.completedTrailIds = const [],
  });

  UserLearningProfile copyWith({
    int? currentLearningLevel,
    int? xpGlobal,
    List<String>? completedTrailIds,
  }) {
    return UserLearningProfile(
      userId: userId,
      currentLearningLevel: currentLearningLevel ?? this.currentLearningLevel,
      xpGlobal: xpGlobal ?? this.xpGlobal,
      completedTrailIds: completedTrailIds ?? this.completedTrailIds,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    currentLearningLevel,
    xpGlobal,
    completedTrailIds,
  ];
}
