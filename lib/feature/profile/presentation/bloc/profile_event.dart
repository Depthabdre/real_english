part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the screen is first opened.
class LoadUserProfile extends ProfileEvent {}

/// Triggered when the user clicks "Save" in the Edit Profile modal.
class UpdateUserProfile extends ProfileEvent {
  final String? fullName;
  final File? imageFile;

  const UpdateUserProfile({this.fullName, this.imageFile});

  @override
  List<Object?> get props => [fullName, imageFile];
}
