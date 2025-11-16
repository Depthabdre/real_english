import 'package:hive/hive.dart';
import '../../domain/entities/level_completion_status.dart';

// This is required for the HIVE build runner to generate the TypeAdapter.
part 'level_completion_status_model.g.dart';

// We DO use @HiveType for local storage generation.
// We do NOT use @JsonSerializable.
@HiveType(typeId: 9) // Ensure this typeId is unique in your project
class LevelCompletionStatusModel extends LevelCompletionStatus {
  const LevelCompletionStatusModel({
    required super.didLevelUp,
    required super.newLevel,
  });

  /// This factory is written manually to parse JSON from the API,
  /// exactly like your `ChoiceModel` example.
  factory LevelCompletionStatusModel.fromJson(Map<String, dynamic> json) {
    return LevelCompletionStatusModel(
      didLevelUp: json['did_level_up'] as bool,
      newLevel: json['new_level'] as int,
    );
  }

  /// This method is written manually to convert the model to JSON.
  Map<String, dynamic> toJson() {
    return {'did_level_up': didLevelUp, 'new_level': newLevel};
  }

  // --- Hive Fields for the hive_generator ---
  @override
  @HiveField(0)
  bool get didLevelUp => super.didLevelUp;

  @override
  @HiveField(1)
  int get newLevel => super.newLevel;
}
