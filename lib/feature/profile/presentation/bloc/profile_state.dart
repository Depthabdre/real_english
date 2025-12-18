part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile user;

  // Used to show a spinner on the "Save" button inside the modal
  // without replacing the whole screen with a loading bar.
  final bool isUpdating;

  const ProfileLoaded({required this.user, this.isUpdating = false});

  ProfileLoaded copyWith({UserProfile? user, bool? isUpdating}) {
    return ProfileLoaded(
      user: user ?? this.user,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [user, isUpdating];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
