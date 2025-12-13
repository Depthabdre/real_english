import 'package:equatable/equatable.dart';

class ImmersionShort extends Equatable {
  final String id;
  final String youtubeId; // The ID needed by the player (e.g., dQw4w9WgXcQ)

  // UI Overlay Data
  final String title;
  final String description; // Used for the "Long Press" translation card
  final String difficultyLabel; // 'beginner', 'intermediate', 'advanced'
  final String category; // 'funny', 'real_life', etc.

  // User Interaction State
  final bool isSaved; // To determine if the heart icon is red or white
  final bool isWatched;

  const ImmersionShort({
    required this.id,
    required this.youtubeId,
    required this.title,
    required this.description,
    required this.difficultyLabel,
    required this.category,
    this.isSaved = false,
    this.isWatched = false,
  });

  // Helper to create a copy of the entity with updated state
  // Useful when the user clicks "Heart" without refetching from API
  ImmersionShort copyWith({bool? isSaved, bool? isWatched}) {
    return ImmersionShort(
      id: id,
      youtubeId: youtubeId,
      title: title,
      description: description,
      difficultyLabel: difficultyLabel,
      category: category,
      isSaved: isSaved ?? this.isSaved,
      isWatched: isWatched ?? this.isWatched,
    );
  }

  @override
  List<Object?> get props => [
    id,
    youtubeId,
    title,
    description,
    difficultyLabel,
    category,
    isSaved,
    isWatched,
  ];
}
