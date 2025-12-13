part of 'immersion_bloc.dart';

abstract class ImmersionState extends Equatable {
  const ImmersionState();

  @override
  List<Object?> get props => [];
}

class ImmersionInitial extends ImmersionState {}

class ImmersionLoading extends ImmersionState {}

class ImmersionLoaded extends ImmersionState {
  final List<ImmersionShort> shorts;
  final bool hasReachedMax; // For pagination later
  final String currentCategory; // 'mix', 'funny', etc.

  const ImmersionLoaded({
    required this.shorts,
    this.hasReachedMax = false,
    this.currentCategory = 'mix',
  });

  /// Helper to update specific fields without rewriting the whole state
  ImmersionLoaded copyWith({
    List<ImmersionShort>? shorts,
    bool? hasReachedMax,
    String? currentCategory,
  }) {
    return ImmersionLoaded(
      shorts: shorts ?? this.shorts,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentCategory: currentCategory ?? this.currentCategory,
    );
  }

  @override
  List<Object?> get props => [shorts, hasReachedMax, currentCategory];
}

class ImmersionError extends ImmersionState {
  final String message;

  const ImmersionError(this.message);

  @override
  List<Object> get props => [message];
}
