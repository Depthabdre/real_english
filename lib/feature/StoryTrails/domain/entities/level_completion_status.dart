import 'package:equatable/equatable.dart';


/// A class to hold the result of completing a story trail.
/// It indicates whether the user has leveled up and what their new level is.
class LevelCompletionStatus extends Equatable {
  /// `true` if the user completed the last story of their level.
  final bool didLevelUp;

  /// The user's current level after the operation.
  /// This will be the old level if they didn't level up, or the new level if they did.
  final int newLevel;

  const LevelCompletionStatus({
    required this.didLevelUp,
    required this.newLevel,
  });

  @override
  List<Object?> get props => [didLevelUp, newLevel];
}
