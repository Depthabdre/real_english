import 'package:real_english/feature/StoryTrails/domain/entities/story_progress.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_segment.dart';
import 'package:real_english/feature/StoryTrails/domain/entities/story_trails.dart';

import 'story_segment_model.dart';
import 'story_progress_model.dart';
import 'package:hive/hive.dart';

part 'story_trail_model.g.dart';

@HiveType(typeId: 0) // Unique ID for StoryTrailModel
class StoryTrailModel extends StoryTrail {
  const StoryTrailModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.difficultyLevel,
    required List<StorySegmentModel> segments,
    super.userProgress,
  }) : super(segments: segments);

  factory StoryTrailModel.fromJson(Map<String, dynamic> json) {
    return StoryTrailModel(
      // 1. Safely handle ID (Default to empty string if missing)
      id: json['id'] as String? ?? '',

      // 2. Safely handle Title
      title: json['title'] as String? ?? 'Untitled Story',

      // 3. Safely handle Description (This often comes back null from AI)
      description: json['description'] as String? ?? '',

      // 4. CRITICAL FIX: Handle Image URL
      // The AI might return null, OR it might use 'imageUrl' instead of 'image_url'.
      // We check both, and fall back to a placeholder if both are null.
      imageUrl:
          (json['image_url'] ?? json['imageUrl']) as String? ??
          'https://via.placeholder.com/300?text=No+Image',

      // 5. Safely handle Difficulty (Default to 1)
      difficultyLevel:
          (json['difficulty_level'] ?? json['difficultyLevel']) as int? ?? 1,

      // 6. Safely handle Segments (If list is null, return empty list)
      segments:
          (json['segments'] as List<dynamic>?)
              ?.map(
                (e) => StorySegmentModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],

      // 7. User Progress (Already handled safely in your code, kept as is)
      userProgress: json['user_progress'] != null
          ? StoryProgressModel.fromJson(
              json['user_progress'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'difficulty_level': difficultyLevel,
      'segments': (segments as List<StorySegmentModel>)
          .map((e) => e.toJson())
          .toList(),
      'user_progress': (userProgress as StoryProgressModel?)?.toJson(),
    };
  }

  @override
  @HiveField(0)
  String get id => super.id;

  @override
  @HiveField(1)
  String get title => super.title;

  @override
  @HiveField(2)
  String get description => super.description;

  @override
  @HiveField(3)
  String get imageUrl => super.imageUrl;

  @override
  @HiveField(4)
  int get difficultyLevel => super.difficultyLevel;

  @override
  @HiveField(5)
  List<StorySegment> get segments => super.segments;

  @override
  @HiveField(6)
  StoryProgress? get userProgress => super.userProgress;
}
