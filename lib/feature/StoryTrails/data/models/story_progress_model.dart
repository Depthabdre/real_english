import 'package:real_english/feature/StoryTrails/domain/entities/challenge_attempt.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_progress.dart';
import 'challenge_attempt_model.dart';
import 'package:hive/hive.dart';

part 'story_progress_model.g.dart';

@HiveType(typeId: 6)
class StoryProgressModel extends StoryProgress {
  /// This field holds the specific Model type and is the source of truth within this class.
  @HiveField(2)
  final Map<String, ChallengeAttemptModel> modelChallengeAttempts;

  const StoryProgressModel({
    required super.storyTrailId,
    super.currentSegmentIndex,
    this.modelChallengeAttempts = const {}, // Initialize the model's own map
    super.isCompleted,
    super.completionDate,
    super.xpEarned,
  }) : super(
         challengeAttempts: modelChallengeAttempts,
       ); // Pass it up to the parent entity

  factory StoryProgressModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? attemptsJson =
        json['challenge_attempts'] as Map<String, dynamic>?;

    Map<String, ChallengeAttemptModel> challengeAttempts = {};
    if (attemptsJson != null) {
      challengeAttempts = attemptsJson.map(
        (key, value) => MapEntry(
          key,
          // CORRECT
          ChallengeAttemptModel.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

    return StoryProgressModel(
      storyTrailId: json['story_trail_id'] as String,
      currentSegmentIndex: json['current_segment_index'] as int,
      modelChallengeAttempts: challengeAttempts,
      isCompleted: json['is_completed'] as bool,
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'] as String)
          : null,
      xpEarned: json['xp_earned'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'story_trail_id': storyTrailId,
      'current_segment_index': currentSegmentIndex,
      'challenge_attempts': modelChallengeAttempts.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'is_completed': isCompleted,
      'completion_date': completionDate?.toIso8601String(),
      'xp_earned': xpEarned,
    };
  }

  StoryProgressModel copyWith({
    String? storyTrailId,
    int? currentSegmentIndex,
    Map<String, ChallengeAttemptModel>? challengeAttempts,
    bool? isCompleted,
    DateTime? completionDate,
    int? xpEarned,
  }) {
    return StoryProgressModel(
      storyTrailId: storyTrailId ?? this.storyTrailId,
      currentSegmentIndex: currentSegmentIndex ?? this.currentSegmentIndex,
      // FIX: Use the explicit model field `this.modelChallengeAttempts` as the fallback.
      // This guarantees the type is Map<String, ChallengeAttemptModel>.
      modelChallengeAttempts: challengeAttempts ?? this.modelChallengeAttempts,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
      xpEarned: xpEarned ?? this.xpEarned,
    );
  }

  // --- HiveField Overrides for inherited properties ---

  @override
  @HiveField(0)
  String get storyTrailId => super.storyTrailId;

  @override
  @HiveField(1)
  int get currentSegmentIndex => super.currentSegmentIndex;

  // The overridden getter now simply points to our explicit model field.
  @override
  Map<String, ChallengeAttempt> get challengeAttempts => modelChallengeAttempts;

  @override
  @HiveField(3)
  bool get isCompleted => super.isCompleted;

  @override
  @HiveField(4)
  DateTime? get completionDate => super.completionDate;

  @override
  @HiveField(5)
  int get xpEarned => super.xpEarned;
}
