import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.identity,
    required super.habit,
    required super.growth,
  });

  // 1. FROM JSON (Cache/API -> Dart)
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      identity: ProfileIdentityModel.fromJson(json['identity'] ?? {}),
      habit: ProfileHabitModel.fromJson(json['habit'] ?? {}),
      growth: ProfileGrowthModel.fromJson(json['growth'] ?? {}),
    );
  }

  // 2. TO JSON (Dart -> Cache)
  Map<String, dynamic> toJson() {
    return {
      'identity': (identity as ProfileIdentityModel).toJson(),
      'habit': (habit as ProfileHabitModel).toJson(),
      'growth': (growth as ProfileGrowthModel).toJson(),
    };
  }
}

// --- SUB-MODELS (Handling the nested data) ---

class ProfileIdentityModel extends ProfileIdentity {
  const ProfileIdentityModel({
    required super.fullName,
    required super.avatarUrl,
    required super.joinedAt,
  });

  factory ProfileIdentityModel.fromJson(Map<String, dynamic> json) {
    return ProfileIdentityModel(
      fullName: json['fullName'] ?? 'Gardener',
      avatarUrl: json['avatarUrl'] ?? '',
      // Convert String to Date
      joinedAt: DateTime.parse(
        json['joinedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      // Convert Date to String
      'joinedAt': joinedAt.toIso8601String(),
    };
  }
}

class ProfileHabitModel extends ProfileHabit {
  const ProfileHabitModel({
    required super.currentStreak,
    required super.isStreakActive,
    required super.lastActiveDate,
  });

  factory ProfileHabitModel.fromJson(Map<String, dynamic> json) {
    return ProfileHabitModel(
      currentStreak: json['currentStreak'] ?? 0,
      isStreakActive: json['isStreakActive'] ?? false,
      lastActiveDate: DateTime.parse(
        json['lastActiveDate'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'isStreakActive': isStreakActive,
      'lastActiveDate': lastActiveDate.toIso8601String(),
    };
  }
}

class ProfileGrowthModel extends ProfileGrowth {
  const ProfileGrowthModel({
    required super.treeStage,
    required super.totalPoints,
    required super.stats,
  });

  factory ProfileGrowthModel.fromJson(Map<String, dynamic> json) {
    return ProfileGrowthModel(
      treeStage: json['treeStage'] ?? 'seed',
      totalPoints: json['totalPoints'] ?? 0,
      stats: GrowthStatsModel.fromJson(json['stats'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treeStage': treeStage,
      'totalPoints': totalPoints,
      'stats': (stats as GrowthStatsModel).toJson(),
    };
  }
}

class GrowthStatsModel extends GrowthStats {
  const GrowthStatsModel({
    required super.storiesCompleted,
    required super.shortsWatched,
  });

  factory GrowthStatsModel.fromJson(Map<String, dynamic> json) {
    return GrowthStatsModel(
      storiesCompleted: json['storiesCompleted'] ?? 0,
      shortsWatched: json['shortsWatched'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storiesCompleted': storiesCompleted,
      'shortsWatched': shortsWatched,
    };
  }
}
