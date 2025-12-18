import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_profile_identity.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile getUserProfile;
  final UpdateProfileIdentity updateProfileIdentity;

  ProfileBloc({
    required this.getUserProfile,
    required this.updateProfileIdentity,
  }) : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadProfile);
    on<UpdateUserProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    // Call UseCase
    final result = await getUserProfile(const GetUserProfileParams());

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (userProfile) => emit(ProfileLoaded(user: userProfile)),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Safety check: We can only update if we are already loaded
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      // 1. Set 'isUpdating' to true (Shows spinner on the button)
      emit(currentState.copyWith(isUpdating: true));

      // 2. Call API
      final result = await updateProfileIdentity(
        UpdateProfileParams(
          fullName: event.fullName,
          imageFile: event.imageFile,
        ),
      );

      result.fold(
        (failure) {
          // 3a. Failure: Turn off spinner, keep old data, show error
          // We assume the UI listens for ProfileError to show a Snackbar.
          // Note: If you want to keep the UI visible but show an error toast,
          // you might want to use a specific "UpdateFailed" state or Listeners.
          // For now, we revert the loading state.
          emit(currentState.copyWith(isUpdating: false));

          // Ideally, we emit a side effect here, but for this pattern:
          emit(ProfileError(failure.message));
          // Note: This replaces the garden with an error screen.
          // In a production app, you'd use a BlocListener for errors
          // to avoid losing the view, but this matches your simple pattern.
        },
        (updatedProfile) {
          // 3b. Success: Update data and turn off spinner
          emit(ProfileLoaded(user: updatedProfile, isUpdating: false));
        },
      );
    }
  }
}
