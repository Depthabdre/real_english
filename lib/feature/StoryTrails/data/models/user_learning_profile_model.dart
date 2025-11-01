import 'package:real_english/feature/StoryTrails/domain/entities/user_learning_profile.dart';
import 'package:hive/hive.dart';

part 'user_learning_profile_model.g.dart';

@HiveType(typeId: 8) // Unique ID for UserLearningProfileModel
class UserLearningProfileModel extends UserLearningProfile {
  const UserLearningProfileModel({
    required super.userId,
    super.currentLearningLevel,
    super.xpGlobal,
    super.completedTrailIds,
  });

  factory UserLearningProfileModel.fromJson(Map<String, dynamic> json) {
    return UserLearningProfileModel(
      userId: json['user_id'] as String,
      currentLearningLevel: json['current_learning_level'] as int? ?? 1,
      xpGlobal: json['xp_global'] as int? ?? 0,
      completedTrailIds:
          (json['completed_trail_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_learning_level': currentLearningLevel,
      'xp_global': xpGlobal,
      'completed_trail_ids': completedTrailIds,
    };
  }

  // ADD THIS METHOD
  @override
  UserLearningProfileModel copyWith({
    String? userId,
    int? currentLearningLevel,
    int? xpGlobal,
    List<String>? completedTrailIds,
  }) {
    return UserLearningProfileModel(
      userId: userId ?? this.userId,
      currentLearningLevel: currentLearningLevel ?? this.currentLearningLevel,
      xpGlobal: xpGlobal ?? this.xpGlobal,
      completedTrailIds: completedTrailIds ?? this.completedTrailIds,
    );
  }

  @override
  @HiveField(0)
  String get userId => super.userId;

  @override
  @HiveField(1)
  int get currentLearningLevel => super.currentLearningLevel;

  @override
  @HiveField(2)
  int get xpGlobal => super.xpGlobal;

  @override
  @HiveField(3)
  List<String> get completedTrailIds => super.completedTrailIds;
}
