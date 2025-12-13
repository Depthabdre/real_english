import '../../domain/entities/immersion_short.dart';

class ImmersionShortModel extends ImmersionShort {
  const ImmersionShortModel({
    required super.id,
    required super.youtubeId,
    required super.title,
    required super.description,
    required super.difficultyLabel,
    required super.category,
    super.isSaved,
    super.isWatched,
  });

  factory ImmersionShortModel.fromJson(Map<String, dynamic> json) {
    return ImmersionShortModel(
      // 1. Map ID (ensure string)
      id: json['id'] as String? ?? '',

      // 2. Map YouTube ID (Critical)
      youtubeId: json['youtubeId'] as String? ?? '',

      // 3. UI Metadata (with clean fallbacks)
      title: json['title'] as String? ?? 'English Short',
      description: json['description'] as String? ?? '',

      // 4. Smart Tags
      difficultyLabel: json['difficultyLevel'] as String? ?? 'intermediate',
      category: json['category'] as String? ?? 'mix',

      // 5. User Interaction State (Defaults to false)
      isSaved: json['isSaved'] as bool? ?? false,
      isWatched: json['isWatched'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'youtubeId': youtubeId,
      'title': title,
      'description': description,
      'difficultyLevel': difficultyLabel,
      'category': category,
      'isSaved': isSaved,
      'isWatched': isWatched,
    };
  }
}
