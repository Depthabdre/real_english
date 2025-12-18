import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  // 1. Identity: The Gardener
  final ProfileIdentity identity;

  // 2. Habit: The Sun (Streak)
  final ProfileHabit habit;

  // 3. Growth: The Tree
  final ProfileGrowth growth;

  const UserProfile({
    required this.identity,
    required this.habit,
    required this.growth,
  });

  // Helper to update state locally (optimistic updates)
  UserProfile copyWith({
    ProfileIdentity? identity,
    ProfileHabit? habit,
    ProfileGrowth? growth,
  }) {
    return UserProfile(
      identity: identity ?? this.identity,
      habit: habit ?? this.habit,
      growth: growth ?? this.growth,
    );
  }

  @override
  List<Object?> get props => [identity, habit, growth];
}

// --- SUB-ENTITIES (Value Objects) ---

class ProfileIdentity extends Equatable {
  final String fullName;
  final String avatarUrl; // URL from OBS or asset path
  final DateTime joinedAt;

  const ProfileIdentity({
    required this.fullName,
    required this.avatarUrl,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [fullName, avatarUrl, joinedAt];
}

class ProfileHabit extends Equatable {
  final int currentStreak;
  final bool isStreakActive; // True if practiced TODAY
  final DateTime lastActiveDate;

  const ProfileHabit({
    required this.currentStreak,
    required this.isStreakActive,
    required this.lastActiveDate,
  });

  @override
  List<Object?> get props => [currentStreak, isStreakActive, lastActiveDate];
}

class ProfileGrowth extends Equatable {
  final String
  treeStage; // "seed", "sprout", "sapling", "young_tree", "majestic_tree"
  final int totalPoints;
  final GrowthStats stats;

  const ProfileGrowth({
    required this.treeStage,
    required this.totalPoints,
    required this.stats,
  });

  @override
  List<Object?> get props => [treeStage, totalPoints, stats];
}

class GrowthStats extends Equatable {
  final int storiesCompleted;
  final int shortsWatched;

  const GrowthStats({
    required this.storiesCompleted,
    required this.shortsWatched,
  });

  @override
  List<Object?> get props => [storiesCompleted, shortsWatched];
}
