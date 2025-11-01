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
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      difficultyLevel: json['difficulty_level'] as int,
      segments: (json['segments'] as List<dynamic>)
          .map((e) => StorySegmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
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
