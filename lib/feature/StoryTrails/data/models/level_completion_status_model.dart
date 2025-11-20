import 'package:hive/hive.dart';
import '../../domain/entities/level_completion_status.dart';

part 'level_completion_status_model.g.dart';

@HiveType(typeId: 9)
class LevelCompletionStatusModel extends LevelCompletionStatus {
  const LevelCompletionStatusModel({
    required super.didLevelUp,
    required super.newLevel,
  });

  /// UPDATED: Matches the TypeScript Backend Interface keys (camelCase)
  factory LevelCompletionStatusModel.fromJson(Map<String, dynamic> json) {
    return LevelCompletionStatusModel(
      // Backend sends 'didLevelUp'.
      // We add a fallback to 'did_level_up' just to be safe, and default to false if missing.
      didLevelUp: (json['didLevelUp'] ?? json['did_level_up'] ?? false) as bool,

      // Backend sends 'newLevel'.
      newLevel: (json['newLevel'] ?? json['new_level'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'didLevelUp': didLevelUp, 'newLevel': newLevel};
  }

  // --- Hive Fields ---
  @override
  @HiveField(0)
  bool get didLevelUp => super.didLevelUp;

  @override
  @HiveField(1)
  int get newLevel => super.newLevel;
}
